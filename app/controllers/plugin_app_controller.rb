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

  accept_api_auth :index, :show, :create, :update, :destroy
  #accept_api_auth :index
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

  def update_issue
    issue = Issue.all(:conditions=>{:id=>params[:ids]})
    issue.each do |i|
      stop_time=i.progresstimes.last

      if stop_time
        if stop_time.end_time.blank?
          stop_time.update_attributes(:end_time=>DateTime.now, :closed=>true)
          new_time = ((((DateTime.now - stop_time.start_time.to_datetime)*24*60).to_i)/60.0).round(2)
          i.time_entries.create(:user=>User.current, :hours=>new_time, :activity_id=>8, :spent_on=>Date.today)
        end
      end
      if i.update_attributes(:status_id=>5)
        TableItMailer.close_ticket_plugin_mail(i).deliver
      end
    end
    
    @notice=l(:change_issue_closed)
    respond_to do |format|
      format.js
    end
  end

  def uncheck_issue
    issue= Issue.find(params[:id])
    issue.update_attribute(:status_id, 2)

    @notice=l(:change_issue_revert)
    respond_to do |format|
      format.js
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
      @query.column_names= [:project, :subject, :done_ratio, :assigned_to, :priority,:due_date]
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

  def add_time
    if params[:issue_id] && !params[:time].blank?
      time=TimeEntry.new(:issue_id=>params[:issue_id],:hours=>params[:time], :activity_id=>8, :user=>User.current, :spent_on=>Date.today)
      if time.save
        @clas="notice"
        @notice=l(:time_added)
      else
        @clas="error"
        @notice=l(:cant_add_time)
      end
    else
      @clas="error"
      @notice=l(:cant_add_time)
    end
    respond_to do |format|
      format.js
    end
  end

  def create_issue
    retrieve_query
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    if @query.valid?
      @limit = per_page_option
      @query.column_names= [:project, :subject, :done_ratio, :assigned_to, :tracker, :priority,:due_date]
      @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
        :order => sort_clause)
      @issue_count_by_group = @query.issue_count_by_group
    end
    call_hook(:controller_plugin_app_index_before_save, { :params => params, :issue => @issue })

    
    @cf =CustomField.find(:first, :conditions=>{:name=>params[:end_time_field_tag]})
    if @cf
      @issue.custom_values.build(:value=> params[:end_time], :custom_field_id=>@cf.id, :customized_type=>"Issue")
    end
    if !params[:end_time].blank? && @issue.due_date.blank?
      @issue.due_date=Date.today
    end

    @issues=@issues.paginate :page => params[:page], :per_page => @limit ? @limit : 25

    @error_messages = ""
    if @issue.save
      add_attach_files(@issue, params[:attachments])
      call_hook(:controller_issues_new_after_save, { :params => params, :issue => @issue})
      
      @saved = true
    else
      @saved = false
      @error_messages = error_messages_for_issue('issue')    
    end
    logger.debug @error_messages.inspect
    respond_to do |format|
      format.js
    end
  end

  def change_to_in_progress
    issue=Issue.find(params[:issue_id])

    if issue.update_attribute(:status_id, 2)
      clas = 'notice'
      notice = l(:changed_to_in_progress)
    else
      clas='error'
      notice = l(:cant_change_to_in_progress)
    end
    render :update do |page|
      page << "if ($('response')) {"
      page.remove 'response'
      page.insert_html :top, 'table-it-issue-list', '<div id="response" class="flash '+clas+'">'+notice+'</div>'
      page << "}else{"
      page.insert_html :top, 'table-it-issue-list', '<div id="response" class="flash '+clas+'">'+notice+'</div>'
      page << "}"
      page.delay(2) do
        page.visual_effect(:fade, 'response', :duration=>1)
      end
    end
  end

  def start_time
    issue=Issue.find(params[:issue_id])
    issue.progresstimes.create(:issue_id=>params[:issue_id], :start_time=>DateTime.now)
    if issue.status_id !=2
      issue.update_attribute(:status_id, 2)
    end
    render :nothing => true
  end

  def stop_time
    issue=Issue.find(params[:issue_id])
    stop_time=issue.progresstimes.last

    stop_time.update_attributes(:end_time=>DateTime.now, :closed=>true)
    new_time = ((((DateTime.now - stop_time.start_time.to_datetime)*24*60).to_i)/60.0).round(2)
    issue.time_entries.create(:user=>User.current, :hours=>new_time, :activity_id=>8, :spent_on=>Date.today)

    render :nothing => true
  end

  def poke
    issue=Issue.find(params[:id])

    if TableItMailer.poke_mail(issue).deliver
      @clas='notice'
      @notice="poked"
    else
      @clas="error"
      @notice="can't poke"
    end
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
  def build_new_issue_from_params
    if params[:id].blank?
      @issue = Issue.new(params[:issue])
    end
    @issue.author = User.current
    @issue.start_date ||= Date.today
    if params[:issue].is_a?(Hash)
      @issue.safe_attributes = params[:issue]
      if User.current.allowed_to?(:add_issue_watchers, @project) && @issue.new_record?
        @issue.watcher_user_ids = params[:issue]['watcher_user_ids']
      end
    end
    @priorities = IssuePriority.all
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current, true)
  end

  def add_attach_files(obj, attachments)
    attached = []
    if attachments && attachments.is_a?(Hash)
      attachments.each_value do |attachment|
        file = attachment['file']
        next unless file && file.size > 0
        a = Attachment.create(:container => obj,
          :file => file,
          :description => attachment['description'].to_s.strip,
          :author => User.current)
        obj.attachments << a

        if a.new_record?
          obj.unsaved_attachments ||= []
          obj.unsaved_attachments << a
        else
          attached << a
        end
      end
    end
    {:files => attached, :unsaved => obj.unsaved_attachments}
  end


  def dont_show_tickets_from_project
    project = Project.find(:first, :conditions=>{:name=>'projekty'})
    
    forbidden_issues=[]
    if project
      project.children.each do |c|
        forbidden_issues<< c.id
      end
    end
    return forbidden_issues
  end
end
