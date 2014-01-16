module IssuesControllerPatch
  extend ActiveSupport::Concern
  
  included do
    prepend_before_filter :clear_filter_from_empty_values, only: [:index]
    skip_before_filter :authorize
    before_filter :xfind_issue, only: [:poke, :time]
    before_filter :authorize, except: [:index]
    before_filter :find_projects_and_users, only: [:index]

    accept_api_auth :poke, :time
  end

  def poke
    respond_to do |format|
      format.js
    end
  end

  def time
    time = params[:time]

    @success = true

    if params[:switch] === true
      @success = if @issue.started?
        @issue.stop_time!
      else
        @issue.start_time!
      end        
    elsif time === true
      @success = @issue.start_time!
    elsif time === false
      @success = @issue.stop_time!
    else
      tentry = @issue.time_entries.create hours: time,
        activity_id: 8,
        user: User.current,
        spent_on: Date.today
      @notice = true
      @success = tentry.errors.empty?
    end

    respond_to do |format|
      format.json
      format.js
    end
    
  end

  private

  def xfind_issue
    find_issue
  end

  def find_projects_and_users
    @projects = Project.order('lft')
    @users = User
      .select("*, (id = #{User.current.id}) as current")
      .where(type: 'User', status: User::STATUS_ACTIVE)
      .order('current DESC')
  end

  def clear_filter_from_empty_values
    assigned_to = params[:v].try(:[], :assigned_to_id)
    if assigned_to.blank? || (assigned_to.kind_of?(Array) && assigned_to.one? && assigned_to.first.blank?)
      params[:f].delete("assigned_to_id") if params[:f].kind_of?(Array)
      params[:op].delete("assigned_to_id") if params[:op].kind_of?(Array)
    end

    project_id = params[:v].try(:[], :project_id)
    if project_id.blank? || (project_id.kind_of?(Array) && project_id.one? && project_id.first.blank?)
      params[:f].delete("project_id") if params[:f].kind_of?(Array)
      params[:op].delete("project_id") if params[:op].kind_of?(Array)
    end
  end

end

IssuesController.send(:include, IssuesControllerPatch)