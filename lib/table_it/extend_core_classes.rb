require_dependency 'issue'
require_dependency 'custom_field'
require_dependency 'issue'

module ProjectExtension
  extend ActiveSupport::Concern

  def default_user_id
    project_users_hash = JSON.load(Setting.plugin_table_it[:default_users])
    login = project_users_hash.find do |key, value|
      key == identifier
    end.try(:last)

    User.where(login: login).last.try(:id) if login.present?
  rescue SyntaxError
    Rails.logger.error "Fix JSON syntax in TableIt settings"
    nil
  end
end

module CustomFieldExtension
  extend ActiveSupport::Concern

  def name
    n = read_attribute(:name)
    I18n.t(:"field_#{n.gsub(/\s+/,'_').downcase}", default: n.humanize)
  end

end

module IssueExtension
  extend ActiveSupport::Concern

  included do
    has_many :progresstimes, dependent: :destroy

    scope :started, lambda { joins(:progresstimes).where(progresstimes: {closed: [false, nil]}) }
    before_update :stop_time_if_closed
  end

  def started?
    progresstimes.where(closed: [false, nil]).any?
  end

  def start_time!
    unless started?
      update_attributes(status_id: 2)
      progresstimes.create(
        start_time: DateTime.now
      )
      true
    else
      false
    end
  end

  def stop_time!
    if started?
      time = progresstimes.started.last.close!
      if time > 0
        time_entries
          .create(
            user: self.assigned_to || User.current,
            hours: time,
            activity_id: 8,
            spent_on: Date.today
          )
      end
      progresstimes.started.delete_all
      true
    else
      false
    end
  end


  def table_status
    case status_id
      when 1 then :new
      when 2 then :progress
      when 3 then :resolved
      when 4 then :feedback
      when 5 then :closed
    end
  end

  def stop_time_if_closed
    if closed? and started?
      self.stop_time!
    end
  end

  def table_it_close!
    status_id = (Setting.plugin_table_it[:close_status] || 5).to_i
    self.update_attributes(status_id: status_id)
  end

  def table_it_reopen!
    status_id = (Setting.plugin_table_it[:inprogress_status] || 2).to_i
    self.update_attributes(status_id: status_id)
  end

end


module UserExtension
  extend ActiveSupport::Concern


  def stop_progress!
    Issue.where(assigned_to_id: self.id).map do |issue|
      issue.stop_time!
    end
  end

  def ticking?
    Issue
      .joins(:progresstimes)
      .where(assigned_to_id: self.id, progresstimes: {closed: [false, nil]})
      .any?
  end

  def default_activity(project)
    defaults = JSON.load(Setting.plugin_table_it[:default_activity]) || {}
    roles = roles_for_project(project).map(&:id)

    aids = defaults.find_all do |key, value|
      roles.include?(key.to_i)
    end.map(&:last).map(&:to_i)

    unless aids.empty?
      TimeEntryActivity.where(id: aids).first
    else
      TimeEntryActivity.where(id: roles).first || TimeEntryActivity.first
    end
  rescue SyntaxError
    Rails.logger.error "Fix JSON syntax in TableIt settings"
    nil
  end
end

User.send(:include, UserExtension)
Project.send(:include, ProjectExtension)
CustomField.send(:include, CustomFieldExtension)
Issue.send(:include, IssueExtension)
