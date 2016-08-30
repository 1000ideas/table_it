module IssuesControllerPatch
  extend ActiveSupport::Concern

  included do
    before_filter :find_projects_and_users, only: [:index]
    before_filter :remove_empty_p_tags, only: [:new]
  end

  private

  def find_projects_and_users
    @projects = Project.has_module(:table_it).allowed_to(:edit_issues).order('lft')
    @users = User
             .select("*, (id = #{User.current.id}) as current")
             .where(type: 'User', status: User::STATUS_ACTIVE)
             .order('current DESC')
  end

  def remove_empty_p_tags
    if params[:copy_from].present? && @issue.description.present?
      @issue.description.gsub!('<p><p', '<p')
      @issue.description.gsub!('</p></p>', '</p>')
      @issue.description.gsub!('<p></p>', '')
    end
  end
end

IssuesController.send(:include, IssuesControllerPatch)
