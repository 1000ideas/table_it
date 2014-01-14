module IssuesHelperPatch
  extend ActiveSupport::Concern

  def issue_status_action(issue)
    content_tag(:b, "SA")
  end

  def issue_actions(issue)
    buttons = []
    buttons << link_to(l(:poke), {controller: :plugin_app, action: :poke, id: issue.id}, class: "status-icon poke") if issue.author == User.current
    buttons.join.html_safe
  end

end

IssuesHelper.send(:include, IssuesHelperPatch)