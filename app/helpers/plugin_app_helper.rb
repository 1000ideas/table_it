module PluginAppHelper

  def time_left(issue, field_name)

    if !issue.due_date.nil?
      if !issue.custom_field_values.blank?
        is=issue.custom_field_values.find{|v| v.custom_field.name==field_name}

        offset = Time.now.utc_offset/3600
        if !issue.due_date.nil? && !is.value.blank?
          str = issue.due_date.to_s+' '+is.value+(offset>0? '+'+offset.to_s : offset.to_s)
          toend = is.value
        else
          str = issue.due_date.tomorrow.to_s+' 00:00'+(offset>0? '+'+offset.to_s : offset.to_s)
          toend = "00:00"
        end
        end_date = DateTime.parse(str)

        if end_date.past?
          time_left = ((DateTime.now- end_date)*24*60).to_i
          left = (time_left/60).to_s+':'+(time_left%60).to_s
          left = left+' '+l(:late)
        else
          time_left = ((end_date - DateTime.now)*24*60).to_i
          left = (time_left/60).to_s+':'+(time_left%60).to_s
          left=left+' ('+l(:to)+' '+toend+')'
        end

      end

    end
    return left
  end
  
  def error_messages_for_issue(*objects)
    html = ""
    objects = objects.map {|o| o.is_a?(String) ? instance_variable_get("@#{o}") : o}.compact
    errors = objects.map {|o| o.errors.full_messages}.flatten
    if errors.any?
      html << "<div id='errorExplanation'><ul>"
      errors.each do |error|
        html << "<li>#{error}</li>"
      end
      html << "</ul></div>"
    end
    html.html_safe
  end

end
