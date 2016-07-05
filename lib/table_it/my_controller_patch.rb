module MyControllerPatch
  extend ActiveSupport::Concern

  included do
    before_filter :find_issue, only: [:index, :page, :manage_task]
  end

  def manage_task
    redirect_to my_page_url
  end

  private

  def find_issue
    if (user = User.current).ticking?
      @issue = user.assigned_issues.find { |issue| issue.started_by_user? }
      @issue.stop_time! if params[:start] && params[:start] == "false"
    elsif params[:issue_id]
      @issue = Issue.find(params[:issue_id])
      params[:start] ? @issue.start_time! : @issue.stop_time!
    end
    @user_ticking = User.current.ticking?
  end
end

MyController.send(:include, MyControllerPatch)
