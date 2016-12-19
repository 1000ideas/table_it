require_dependency 'issue'
require_dependency 'custom_field'

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
    cattr_accessor :skip_callbacks

    scope :started, -> { joins(:progresstimes).where(progresstimes: { closed: [false, nil] }) }
    before_update :stop_time_if_closed
    before_create :wrap_with_p_tags
    before_save :add_parent_id_to_issue
    after_update :update_spent_time, unless: :skip_callbacks
  end

  def started?
    # @@started_issues_ids ||= Progresstime.where(closed: [false, nil]).pluck(:issue_id)
    # @@started_issues_ids.include? id
    # Issue.includes(:progresstimes)
    #      .started
    #      .where('progresstimes.issue_id = ?', self.id)
    #      .any?

    # !progresstimes.find { |pt| !pt.closed }.nil?
    progresstimes.started.any?
  end

  def started_by_user?(u_id = User.current.id)
    # Issue.includes(:progresstimes)
    #      .started
    #      .where('progresstimes.issue_id = ? AND progresstimes.user_id = ?', self.id, u_id)
    #      .any?

    # !progresstimes.find { |pt| !pt.closed && pt.user_id == u_id }.nil?
    progresstimes.started.where(user_id: u_id).any?
  end

  def start_time!
    return false if started_by_user?
    update_attributes(status_id: 2)
    progresstimes.create(
      start_time: DateTime.now,
      user_id: User.current.id
    )
    true
  end

  def stop_time!
    return false unless started?
    if assignees_ids.include?(User.current.id)
      stop_by_assigned_user
    else
      stop_by_admin
    end
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

  def assignees_ids
    extra_users = tracker_accessible_issue_permissions.pluck(:user_id)
    @assignees_ids ||= [extra_users, assigned_to_id].flatten
  end

  def wrap_with_p_tags
    if self.description.slice(0, 3) != '<p>'
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
    cf = custom_field_values.find { |cfv| cfv.custom_field.name =~ /pid/i }

    return if cf.nil?
    return if cf.value.present?
    return unless cf.custom_field.visible_by? cf.customized.project, User.current

    p_id = @parent_issue.try(&:root_id) || root_id

    if p_id.nil? || p_id == id
      cf.value = nil
    elsif p_id != cf.value.to_i
      cf.value = p_id
    end
  end

  private

  def stop_by_assigned_user
    time = progresstimes.started.where(user_id: User.current.id).first.close!
    time_entries.create(
      user: User.current,
      hours: time,
      activity_id: 8,
      spent_on: Date.today
    )
    update_spent_time
  end

  def stop_by_admin
    return unless User.current.admin?
    times = progresstimes.started.each do |time|
      t = time.close!
      time_entries.create(
        user: User.current,
        hours: t,
        activity_id: 8,
        spent_on: Date.today
      )
      update_spent_time
    end
  end

  def update_spent_time
    Issue.skip_callbacks = true
    update_attributes(spent_time: total_spent_hours.round(2))
    Issue.skip_callbacks = false
  end
end

module UserExtension
  extend ActiveSupport::Concern

  def stop_progress!
    Issue.where(assigned_to_id: self.id).map(&:stop_time!)
  end

  def ticking?
    Progresstime.started.where(user_id: self.id).any?
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

User.send(:include, UserExtension)
Project.send(:include, ProjectExtension)
CustomField.send(:include, CustomFieldExtension)
Issue.send(:include, IssueExtension)
