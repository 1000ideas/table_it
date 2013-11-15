require_dependency 'issue'

module ExtendCoreClasses

  def self.included(base)
    base.class_eval do
      has_many :progresstimes, :dependent => :destroy
    end
  end

end

Issue.send(:include, ExtendCoreClasses)