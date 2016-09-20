module TableIt
  class TableItHooks < Redmine::Hook::ViewListener
    render_on :view_layouts_base_body_bottom, partial: 'table_it/on_close'
  end
end
