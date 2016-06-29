require_dependency 'issue'
require_dependency 'custom_field'
require_dependency 'issue'

module ProjectExtension
  extend ActiveSupport::Concern

  def default_user_id
    project_users_hash = JSON.load(Setting.plugin_table_it[:default_users])
    login = project_users_hash.find do |key, _value|
      key == identifier
    end.try(:last)

    User.where(login: login).last.try(:id) if login.present?
  rescue SyntaxError
    Rails.logger.error 'Fix JSON syntax in TableIt settings'
    nil
  end
end

module CustomFieldExtension
  extend ActiveSupport::Concern

  def name
    n = read_attribute(:name)
    I18n.t(:"field_#{n.gsub(/\s+/, '_').downcase}", default: n.humanize)
  end
end

module IssueExtension
  extend ActiveSupport::Concern

  included do
    has_many :progresstimes, dependent: :destroy

    scope :started, -> { joins(:progresstimes).where(progresstimes: { closed: [false, nil] }) }
    before_update :stop_time_if_closed
    before_create :wrap_with_p_tags
    before_save :add_parent_id_to_issue
  end

  def started?
    @@started_issues_ids ||= Progresstime.where(closed: [false, nil]).pluck(:issue_id)
    @@started_issues_ids.include? id
  end

  def start_time!
    return false if started?
    update_attributes(status_id: 2)
    progresstimes.create(
      start_time: DateTime.now,
      user_id: User.current.id
    )
    true
  end

  def stop_time!
    return false unless started?
    time = progresstimes.started.last.close!
    if time > 0
      time_entries.create(
        user: self.assigned_to || User.current,
        hours: time,
        activity_id: 8,
        spent_on: Date.today
      )
    end
    progresstimes.started.delete_all
    true
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
    self.stop_time! if closed? && started?
  end

  def table_it_close!
    status_id = (Setting.plugin_table_it[:close_status] || 5).to_i
    self.update_attributes(status_id: status_id)
  end

  def table_it_reopen!
    status_id = (Setting.plugin_table_it[:inprogress_status] || 2).to_i
    self.update_attributes(status_id: status_id)
  end

  def wrap_with_p_tags
    unless self.description.slice(0, 3) == '<p>'
      text = self.description
      text = text.split("\r\n")
      desc = []
      text.each do |el|
        desc.push("<p>#{el}</p>\r\n\r\n")
      end
      self.description = desc.join
    end
  end

  def add_parent_id_to_issue
    return if (p_id = @parent_issue.try(&:root_id)).nil?
    if (custom_field = self.custom_field_values.find { |cfv| cfv.custom_field.name =~ /pid/i })
      custom_field.value = p_id
    end
  end
end

module UserExtension
  extend ActiveSupport::Concern

  def stop_progress!
    Issue.where(assigned_to_id: self.id).map(&:stop_time!)
  end

  def ticking?
    Issue.joins(:progresstimes)
         .where(assigned_to_id: self.id, progresstimes: { closed: [false, nil] })
         .any?
  end

  def default_activity(project)
    defaults = JSON.load(Setting.plugin_table_it[:default_activity]) || {}
    roles = roles_for_project(project).map(&:id)

    aids = defaults.find_all do |key, _value|
      roles.include?(key.to_i)
    end.map(&:last).map(&:to_i)

    if aids.empty?
      TimeEntryActivity.where(id: roles).first || TimeEntryActivity.first
    else
      TimeEntryActivity.where(id: aids).first
    end
  rescue SyntaxError
    Rails.logger.error 'Fix JSON syntax in TableIt settings'
    nil
  end
end

module TimeEntryExtension
  extend ActiveSupport::Concern

  included do
    after_create :time_entry_added
    after_update :time_entry_added
    before_destroy :time_entry_deleted
  end

  def time_entry_added
    issue = Issue.find(issue_id)
    issue.update_attributes(spent_time: issue.spent_time + hours)
  end

  def time_entry_deleted
    issue = Issue.find(issue_id)
    issue.update_attributes(spent_time: issue.spent_time - hours)
  end
end

User.send(:include, UserExtension)
Project.send(:include, ProjectExtension)
CustomField.send(:include, CustomFieldExtension)
Issue.send(:include, IssueExtension)
TimeEntry.send(:include, TimeEntryExtension)
