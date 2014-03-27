class TableIt::IssuesController < ApplicationController

  before_filter :find_issue, only: [:poke, :time, :close]
  before_filter :find_project_by_project_id, only: [:project_users]
  before_filter :authorize, except: [:stop_time]

  accept_api_auth :poke, :time, :stop_time, :close, :project_users

  def project_users
    @users = @project.users

    respond_to do |format|
      format.js
    end
  end

  def poke
    @success = !!TableItMailer.poke_mail(@issue).try(:deliver)

    respond_to do |format|
      format.js
    end
  end

  def stop_time
    User.current.stop_progress!
    head :ok
  end

  def time
    time = params[:time]
    tentry = nil
    @success = true

    if params[:switch] === true
      @success = if @issue.started?
        @issue.stop_time!
        tentry = @issue.time_entries.last
      else
        @issue.start_time!
      end
    elsif time === true
      @success = @issue.start_time!
    elsif time === false
      @success = @issue.stop_time!
      tentry = @issue.time_entries.last
    else
      tentry = @issue.time_entries.create hours: time,
        activity_id: User.current.default_activity(@issue.project).try(:id),
        user: User.current,
        spent_on: Date.today
      @notice = true
      @success = tentry.errors.empty?
    end

    respond_to do |format|
      format.json { render json: {success: @success, time: tentry.try(:hours)} }
      format.js
    end

  end

  def close
    @issue.init_journal(User.current)

    if params[:reopen]
      @issue.table_it_reopen!
    else
      @issue.table_it_close!
    end

    respond_to do |format|
      format.js
    end
  end
end
