module IssuesControllerPatch
  extend ActiveSupport::Concern

  included do
    before_filter :find_projects_and_users, only: [:index]
  end

  private

  def find_projects_and_users
    @projects = Project.has_module(:table_it).allowed_to(:edit_issues).order('lft')
    @users = User
             .select("*, (id = #{User.current.id}) as current")
             .where(type: 'User', status: User::STATUS_ACTIVE)
             .order('current DESC')
  end
end

IssuesController.send(:include, IssuesControllerPatch)
