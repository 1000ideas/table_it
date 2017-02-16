module TableIt
  class TableItHooks < Redmine::Hook::ViewListener
    render_on :view_layouts_base_body_bottom, partial: 'table_it/on_close'
    render_on :view_issues_form_details_bottom, partial: 'table_it/check_attachments'
  end
end
