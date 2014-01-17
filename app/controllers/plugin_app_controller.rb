#encoding: ascii
class PluginAppController < ApplicationController
  unloadable
  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper
  helper :attachments
  include AttachmentsHelper
  helper :issues
  include IssuesHelper
  include PluginAppHelper

  before_filter :build_new_issue_from_params, :only=>[:create_issue]
  
  accept_api_auth :index, :show, :create, :update,
    :destroy, :start_time, :stop_time, :add_time

  def list
    sort_init 'last_name'
    sort_update %w(first_name last_name)
    @items = Contact.find_all nil, sort_clause
  end

  def index
    retrieve_query
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    if @query.valid?
      @limit = per_page_option
      @query.column_names= [:project, :subject, :done_ratio,:author, :assigned_to, :priority,:due_date]
      @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
        :order => sort_clause
        )
      @issue_count_by_group = @query.issue_count_by_group
    end
    @priorities = IssuePriority.active
    user_projects_manage = []
    User.current.memberships.each do |membership|
       user_projects_manage << membership.project_id if membership.member_roles.select{|mr| mr.role_id == 3}.length > 0
    end
    if params[:filter]
      unless params[:filter][:project].blank?
        @issues = @issues.select{|p| p.project_id==params[:filter][:project].to_i}
      end
      unless params[:filter][:user].blank?
        @issues = @issues.select{|p| p.assigned_to_id == params[:filter][:user].to_i}
      end
      if params[:filter][:admin].blank?
        @issues=@issues.select{|i| i.assigned_to_id==User.current.id || i.author_id==User.current.id || user_projects_manage.include?(i.project_id) || i.watchers.collect(&:user_id).include?(User.current.id)}
      end

      if params[:filter][:started].to_i == 1
        @issues = @issues.select {|i| i.started? }
      end
      
    end

    
    #blokada wyswietlen ticketow z podprojektów 'projekty'
    forbidden_issues=dont_show_tickets_from_project()

    @issues=@issues.select{|i| i.assigned_to_id==User.current.id || User.current.admin? || i.author_id==User.current.id || user_projects_manage.include?(i.project_id) || i.watchers.collect(&:user_id).include?(User.current.id)}
    @issues=@issues.delete_if{|i| forbidden_issues.include?(i.project_id)}

    
    
    @cf = CustomField.find(:first, :conditions=>{:name=>"end_time_field_name"})
    projects=Project.visible.find(:all, :order => 'lft')
    @projects=[]
    projects.each do |p|

      if p.is_public? || User.current.member_of?(p) || User.current.admin?
        @projects<<p
      end
    end

    @issues=@issues.paginate :page => params[:page], :per_page => @limit ? @limit : 25

    respond_to do |format|
      format.html { render :action=> :index, :layout => !request.xhr? }
      format.api
      format.csv  { send_data(issues_to_csv(@issues), :type => 'text/csv; header=present', :filename => 'export.csv') }
    end
  end


  def refresh_issues_list
    retrieve_query
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)

    user_projects_manage = []
    User.current.memberships.each do |membership|
       user_projects_manage << membership.project_id if membership.member_roles.select{|mr| mr.role_id == 3}.length > 0
    end

    if @query.valid?
      @limit = per_page_option
      @query.column_names= [:project, :subject, :done_ratio,:author, :assigned_to, :priority,:due_date]
      @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
        :order => sort_clause)

      forbidden_issues=dont_show_tickets_from_project()

      @issues=@issues.select{|i| i.assigned_to_id==User.current.id || User.current.admin? || i.author_id==User.current.id || user_projects_manage.include?(i.project_id) || i.watchers.collect(&:user_id).include?(User.current.id)}
      @issues=@issues.delete_if{|i| forbidden_issues.include?(i.project_id)}
      @issue_count_by_group = @query.issue_count_by_group
    end
    if params[:filter]
      unless params[:filter][:project].blank?
        @issues = @issues.select{|p| p.project_id==params[:filter][:project].to_i}
      end
      unless params[:filter][:user].blank?
        @issues = @issues.select{|p| p.assigned_to_id==params[:filter][:user].to_i}
      end
      unless params[:filter][:admin].blank?
        @issues = @issues.select{|p| p.assigned_to_id==User.current.id or p.author_id==User.current.id}
      end
    end
    @cf = CustomField.find(:first, :conditions=>{:name=>"end_time_field_name"})
    params[:action] = 'index'
    @issues=@issues.paginate :page => params[:page], :per_page => @limit ? @limit : 25
    
    respond_to do |format|
      format.js
    end
  end 

  def project_users
    project = Project.find(params[:project_id])
    @users = project.users.collect{|us| {name: us.name, id: us.id} }

    render json: @users
    
  end

  private

  def dont_show_tickets_from_project
    
    projects = Project.find(:all, :conditions=>["identifier IN (?)",['1000projekty', "projekty"]])
    
    forbidden_issues=[]
    if projects
      projects.each do |proj|
        forbidden_issues << proj.id
        proj.children.each do |c|
          forbidden_issues<< c.id
        end
      end
    end
    return forbidden_issues
  end
end
