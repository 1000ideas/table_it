module TimelogControllerPatch
  extend ActiveSupport::Concern

  included do
    after_filter :update_issue_spent_time, only: [:create, :destroy]
  end

  private

  def update_issue_spent_time
    Issue.skip_callbacks = true
    @issue.update_attributes(spent_time: @issue.spent_hours.round(2))
    Issue.skip_callbacks = false
  end
end

TimelogController.send(:include, TimelogControllerPatch)
