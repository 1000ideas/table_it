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
end

Issue.send(:include, IssueExtension)