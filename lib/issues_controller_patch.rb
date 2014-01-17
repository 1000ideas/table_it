module IssuesControllerPatch
  extend ActiveSupport::Concern
  
  included do
    prepend_before_filter :clear_filter_from_empty_values, only: [:index]
    prepend_before_filter :find_project_by_project_id, only: [:project_users]
    skip_before_filter :authorize
    before_filter :xfind_issue, only: [:poke, :time, :close]
    before_filter :authorize, except: [:index]
    before_filter :find_projects_and_users, only: [:index]

    accept_api_auth :poke, :time, :close, :project_users

    alias_method_chain :create, :js_response    
  end


  def project_users
    @users = @project.users

    respond_to do |format|
      format.js
    end
  end

  def poke
    @success = !!TableItMailer.poke_mail(@issue).try(:deliver)

    respond_to do |format|
      format.js
    end
  end

  def time
    time = params[:time]

    @success = true

    if params[:switch] === true
      @success = if @issue.started?
        @issue.stop_time!
      else
        @issue.start_time!
      end        
    elsif time === true
      @success = @issue.start_time!
    elsif time === false
      @success = @issue.stop_time!
    else
      tentry = @issue.time_entries.create hours: time,
        activity_id: 8,
        user: User.current,
        spent_on: Date.today
      @notice = true
      @success = tentry.errors.empty?
    end

    respond_to do |format|
      format.json
      format.js
    end
    
  end

  def close
    if params[:reopen]
      @issue.update_attributes(status_id: 2)
    else
      @issue.stop_time!
      @issue.update_attributes(status_id: 5)
    end

    respond_to do |format|
      format.js
    end
  end

  def create_with_js_response
    call_hook(:controller_issues_new_before_save, { :params => params, :issue => @issue })
    @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
    if @issue.save
      call_hook(:controller_issues_new_after_save, { :params => params, :issue => @issue})
      respond_to do |format|
        format.html {
          render_attachment_warning_if_needed(@issue)
          flash[:notice] = l(:notice_issue_successful_create, :id => view_context.link_to("##{@issue.id}", issue_path(@issue), :title => @issue.subject))
          if params[:continue]
            attrs = {:tracker_id => @issue.tracker, :parent_issue_id => @issue.parent_issue_id}.reject {|k,v| v.nil?}
            redirect_to new_project_issue_path(@issue.project, :issue => attrs)
          else
            redirect_to issue_path(@issue)
          end
        }
        format.api  { render :action => 'show', :status => :created, :location => issue_url(@issue) }
        format.js
      end
      return
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@issue) }
        format.js
      end
    end
  end  

  private

  def xfind_issue
    find_issue
  end

  def find_projects_and_users
    @projects = Project.order('lft')
    @users = User
      .select("*, (id = #{User.current.id}) as current")
      .where(type: 'User', status: User::STATUS_ACTIVE)
      .order('current DESC')
  end

  def clear_filter_from_empty_values
    assigned_to = params[:v].try(:[], :assigned_to_id)
    if assigned_to.blank? || (assigned_to.kind_of?(Array) && assigned_to.one? && assigned_to.first.blank?)
      params[:f].delete("assigned_to_id") if params[:f].kind_of?(Array)
      params[:op].delete("assigned_to_id") if params[:op].kind_of?(Array)
    end

    project_id = params[:v].try(:[], :project_id)
    if project_id.blank? || (project_id.kind_of?(Array) && project_id.one? && project_id.first.blank?)
      params[:f].delete("project_id") if params[:f].kind_of?(Array)
      params[:op].delete("project_id") if params[:op].kind_of?(Array)
    end
  end

end

IssuesController.send(:include, IssuesControllerPatch)