module MyControllerPatch
  extend ActiveSupport::Concern

  included do
    before_filter :find_issue, only: [:index, :page]
  end

  private

  def find_issue
    if (user = User.current).ticking?
      @issue = user.assigned_issues.find(&:started_by_user?)
      @issue.stop_time! if params[:start] && params[:start] == 'false'
    elsif params[:issue_id]
      @issue = Issue.find(params[:issue_id])
      params[:start] ? @issue.start_time! : @issue.stop_time!
    end
    @user_ticking = User.current.ticking?
    @note = @issue.try(:journals).try(:last)
    @start_time = @issue.progresstimes.where(user_id: User.current.id).last.try(:start_time) if @issue
    @start_time = Time.parse(@start_time.to_s).in_time_zone('Warsaw') if @start_time
  end
end

MyController.send(:include, MyControllerPatch)
