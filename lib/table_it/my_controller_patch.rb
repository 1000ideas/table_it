module MyControllerPatch
  extend ActiveSupport::Concern

  included do
    before_filter :find_issue, only: [:index, :page, :page_layout]
  end

  private

  def find_issue
    if (user = User.current).ticking?
      @issue = Progresstime.started.where(user_id: user.id).first.issue
      @issue.stop_time! if params[:start] && params[:start] == 'false'
    elsif params[:issue_id]
      @issue = Issue.find(params[:issue_id])
      params[:start] ? @issue.start_time! : @issue.stop_time!
    end
    data_for_view
    shared_issues
  end

  def data_for_view
    @user_ticking = User.current.ticking?
    @note = find_note_with_text
    @start_time = @issue.progresstimes.where(user_id: User.current.id).last.try(:start_time) if @issue
    @start_time = Time.parse(@start_time.to_s).in_time_zone('Warsaw') if @start_time
  end

  def find_note_with_text
    return nil if @issue.nil?
    @issue.journals.reverse.each do |journal|
      return journal if journal.notes.present?
    end
    nil
  end

  def shared_issues
    return unless ActiveRecord::Base.connection.table_exists? 'tracker_accessible_issue_permissions'
    issue_ids = TrackerAccessibleIssuePermission.where(user_id: User.current.id).map(&:issue_id)
    @extra_issues = Issue.where(id: issue_ids)
  end
end

MyController.send(:include, MyControllerPatch)
