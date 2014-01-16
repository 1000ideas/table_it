require_dependency 'issue'

module IssueExtension
  extend ActiveSupport::Concern

  included do
    has_many :progresstimes, dependent: :destroy

    scope :started, lambda { joins(:progresstimes).where(progresstimes: {closed: [false, nil]}) }
  end

  def started?
    progresstimes.where(closed: [false, nil]).any?
  end

  def start_time!
    
  end

  def stop_time!

  end


  def table_status?(status)
    case status_id
      when 1 then :new
      when 2 then :progress
      when 3 then :resolved
      when 4 then :feedback
      when 5 then :closed
    end
  end
end

Issue.send(:include, IssueExtension)