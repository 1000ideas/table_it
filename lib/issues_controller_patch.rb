module IssuesControllerPatch
  extend ActiveSupport::Concern
  
  included do
    before_filter :find_projects_and_users, only: [:index]
    before_filter :clear_filter_from_empty_values, only: [:index]
  end
  
  private

  def find_projects_and_users
    @projects = Project.has_module(:table_it).allowed_to(:edit_issues).order('lft')
    @users = User
      .select("*, (id = #{User.current.id}) as current")
      .where(type: 'User', status: User::STATUS_ACTIVE)
      .order('current DESC')
  end

  def clear_filter_from_empty_values
    return unless request.path == home_path

    params[:set_filter] = '1'

    params[:f] ||= []

    assigned_to = params[:v].try(:[], :assigned_to_id)
    if assigned_to.blank? || (assigned_to.kind_of?(Array) && assigned_to.one? && assigned_to.first.blank?)
      params[:f].delete("assigned_to_id") if params[:f].kind_of?(Array)
      params[:op].delete("assigned_to_id") if params[:op].kind_of?(Array)
    end

    project_id = params[:v].try(:[], :project_id)
    if project_id.blank? || (project_id.kind_of?(Array) && project_id.one? && project_id.first.blank?)
      params[:v] ||= {}
      params[:v][:project_id] = @projects.map(&:id).map(&:to_s)
      params[:op] ||= {}
      params[:op][:project_id] = '='
      params[:f] ||= []
      params[:f].push('project_id') unless params[:f].include?('project_id')
    end

    unless params[:f].include?('status_id')
      params[:f] ||= []
      params[:f].push('status_id')
      params[:op] ||= {}
      params[:op][:status_id] = 'o'
    end
  end

end

IssuesController.send(:include, IssuesControllerPatch)