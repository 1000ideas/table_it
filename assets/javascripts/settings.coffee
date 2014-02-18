class MultipleSelectMatch
  constructor: (@table_class) ->
    $(document).on 'click', ".#{@table_class} + .add-next-match", (event) =>
      event.preventDefault()
      @new_user(event.target)

    $(document).on 'click', ".#{@table_class} .remove-match", (event) =>
      event.preventDefault()
      $(event.target).parents('tr').first().remove()
      @update_json_setting()

    $(document).on 'change', ".#{@table_class} select", =>
      @update_json_setting()

    true

  new_user: (link)->
    template = $( $(link).data('template') )
    $(link).prev().find('tbody').append template
    true

  update_json_setting: ->
    matches = {}
    $(".#{@table_class} tr").each (idx, el) =>
      key = $('select', el).first().val()
      value = $('select', el).last().val()
      if key.length > 0 and value.length > 0
        matches[key] = value

    $("#settings_#{@table_class}").val JSON.stringify(matches)

class PluginSettings
  constructor: ->
    @select_matches = {}
    for name in ['default_users', 'default_activity']
      @select_matches[name] = new MultipleSelectMatch(name)

jQuery -> (window.pluginSettings = new PluginSettings())
