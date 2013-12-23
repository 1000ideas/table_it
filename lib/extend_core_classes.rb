require_dependency 'issue'

module ExtendCoreClasses

  def self.included(base)
    base.class_eval do
      has_many :progresstimes, dependent: :destroy

      def started?
        progresstimes.where(closed: [false, nil]).any?
      end

      scope :started, lambda { joins(:progresstimes).where(progresstimes: {closed: [false, nil]}) }
    end

  end

end

Issue.send(:include, ExtendCoreClasses)