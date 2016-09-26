class Progresstime < ActiveRecord::Base
  belongs_to :issue
  belongs_to :user

  after_update :clear_issues_cache
  after_create :clear_issues_cache

  scope :started, -> { where(closed: [false, nil]) }

  def timediff
    ((end_time - start_time) / 3600.0).round(2) if end_time
  end

  def close!
    update_attributes(end_time: DateTime.now, closed: true)
    timediff
  end

  private

  def clear_issues_cache
    pt = Progresstime.where(closed: [false, nil]).pluck(:issue_id)
    Issue.class_variable_set('@@started_issues_ids', pt)
  end
end
