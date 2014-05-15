module IssuesHelperPatch
  extend ActiveSupport::Concern

  def nl2br(text)
    text.gsub(/\r\n|\r|\n/, '<br />').html_safe
  end

  def issue_tooltip(issue)
    desc = strip_tags(issue.description)
    if desc.length > 300
      desc = desc.slice(0, 299).concat("&hellip;")
    end

    [content_tag(:strong, "#{l(:field_author)}: "), issue.author, tag(:br), nl2br(desc)].join
  end

  def issue_status_action(issue)
    buttons = []
    buttons << content_tag(:span, '', class: [:clip, :'status-icon']) if issue.attachments.any?
    buttons << content_tag(:span, '', class: [:"status-#{issue.table_status}", :'status-icon']) unless issue.table_status == :closed
    if User.current.allowed_to?(:time_actions, issue.project) and !issue.closed?
      data = {remote: true, method: :post}
      path = switch_time_issue_path(issue)
      unless User.current == issue.assigned_to or User.current.admin?
        data.merge!(:"not-yours" => t("alert_not_yours"))
        path = '#'
      end
      buttons << link_to('', path, data: data, class: [:"#{issue.started? ? "stop" : "start"}-time", :'status-icon'])
    end
    buttons.join.html_safe
  end

  def issue_actions(issue)
    buttons = []
    buttons << content_tag(:span) do
      input = text_field_tag(:"add-time-input-#{issue.id}", nil, class: "add-time-input", data: {url: add_time_issue_path(issue, format: :js)})
      button = button_tag(l(:add_time), class: "add-time-button")
      [input, button].join.html_safe
    end
    buttons << link_to('', edit_issue_path(issue), class: 'icon icon-edit')
    if issue.author == User.current && User.current.allowed_to?(:poke, issue.project)
      buttons << link_to(l(:poke), poke_issue_path(issue, format: :js), data: {method: :post, remote: :true}, class: "status-icon poke")
    end
    buttons.join.html_safe
  end

end

IssuesHelper.send(:include, IssuesHelperPatch)
