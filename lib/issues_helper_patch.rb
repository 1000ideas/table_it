module IssuesHelperPatch
  extend ActiveSupport::Concern

  def issue_tooltip(issue)
    desc = strip_tags(issue.description)
    if desc.length > 300
      desc = desc.slice(0, 299).concat("&hellip;")
    end
    [content_tag(:strong, "#{l(:field_author)}: "), issue.author, tag(:br), desc].join
  end

  def issue_status_action(issue)
    content_tag(:b, "SA")
  end

  def issue_actions(issue)
    buttons = []
    buttons << content_tag(:span) do
      input = text_field_tag(:"add-time-input-#{issue.id}", nil, class: "add-time-input", data: {url: add_time_issue_path(issue, format: :js)})
      button = button_tag(l(:add_time), class: "add-time-button")
      [input, button].join.html_safe
    end
    buttons << link_to(l(:poke), poke_issue_path(issue), class: "status-icon poke") if issue.author == User.current
    buttons << link_to('', edit_issue_path(issue), class: 'icon icon-edit')
    buttons.join.html_safe
  end

end

IssuesHelper.send(:include, IssuesHelperPatch)