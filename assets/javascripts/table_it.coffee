class TableIt
  #refresh time in seconds
  @refresh_time = 60

  constructor: ->
    @ticking()
    @_init_toast()
    @_init_time_add()
    @_init_tooltips()
    @_init_new_issue()
    @_init_close_on_tick()
    @_init_toggle_sidebar()
    @_init_auto_refresh()
    @_init_empty_play()
    true

  ticking: ->
    title = $('head title')
    unless title.data('placeholder')?
      title.data('placeholder', title.text())

    default_title = title.data('placeholder')

    if $('table.list.issues').data('ticking')
      title.text("▶ #{default_title}")
    else
      title.text(default_title)

  refresh: (done = (=> @_reset_auto_refresh()) )->
    $.ajax
      url: location.href
      dataType: 'html'
      success: (data) =>
        $("#issues-list-form").replaceWith $(data).filter("#issues-list-form")
        @ticking()
      complete: done

  set_api_key: (key) ->
    @api_key = key

  add_time: (time_input) ->
    time = $(time_input).val()
    url = $(time_input).data('url')

    return if time.length == 0 || !url?

    $.ajax
      dataType: 'script'
      type: 'POST'
      url: url
      data:
        time: time
      complete: ->
        $(time_input).val('')

  set_cookie: (name, value, days = 1) ->
    d = new Date()
    d.setTime( d.getTime() + days*24*60*60*1000 )
    document.cookie = "#{name}=#{value}; expires=#{d.toGMTString()}"

  _init_auto_refresh: ->
    @refresh_timeout_id = setTimeout(
      =>
        @refresh =>
          @_init_auto_refresh()
      TableIt.refresh_time*1000
    )

  _clear_auto_refresh: ->
    clearTimeout(@refresh_timeout_id)

  _reset_auto_refresh: ->
    @_clear_auto_refresh()
    @_init_auto_refresh()

  _init_toggle_sidebar: ->
    status = document.cookie.match(/sidebar=(open|closed)(?:;|$)/)
    if status?
      $('#main').toggleClass('nosidebar', status[1] == 'closed')


    $(document).on 'click', '#toggle-sidebar', (event) =>
      event.preventDefault()

      closed = $(event.target).parents('#main').toggleClass('nosidebar').hasClass('nosidebar')
      @set_cookie('sidebar', (if closed then "closed" else "open"), 365)



  _init_close_on_tick: ->
    $(document).on 'click', '.issues td.checkbox input[type=checkbox]', (event) ->
      event.preventDefault
      checked = $(this).is(':checked')
      closed = $(this).parents('tr.closed').length > 0
      url = $(this).data('url')
      if checked != closed
        $.ajax
          dataType: 'script'
          type: 'POST'
          url: url

  _init_new_issue: ->
    $(document).on 'click', 'h2#new-issue', (event) ->
      event.preventDefault()
      $(this).next().slideToggle('fast');

    $(document).on 'change', '.home-new-issue-form #issue_project_id', (event) ->
      $.ajax
        dataType: 'script'
        type: 'GET'
        data:
          project_id: $(this).val()
        url: $(this).data('url')
        error: ->
          $('.home-new-issue-form #issue_assigned_to_id').html $('<option>')

    $(document).on 'ajax:success', 'form.home-new-issue-form', (event, data) =>
      label = $(event.target).data('success') ? "Success"
      @toast(label, 'notice')
      @refresh()
      $('#issue_subject, #issue_description', event.target).each (idx, el) ->
        $(el).val('')

    $(document).on 'ajax:error', 'form.home-new-issue-form', (event, xhr, status, error) =>
      rsp = JSON.parse xhr.responseText
      if rsp.errors? and rsp.errors.length > 0
        @toast(rsp.errors[0], 'alert')

  _init_empty_play: ->
    $(document).on 'ajax:before', '[data-not-yours]', (event) =>
      @toast( $(event.target).data('not-yours'), 'alert' )
      return false

  _init_time_add: ->
    $(document).on 'click', '.add-time-button', (event) =>
      event.preventDefault()

      @add_time($(event.target).prev())

    $(document).on 'keyup', '.add-time-input', (event) =>
      if event.keyCode == 13
        event.preventDefault()
        @add_time(event.target)

    true


  _init_toast: ->
    @_toast_element()
    $(document).on 'click', '#toast', ->
      id = $(this).data('timeout_id')
      if id?
        clearTimeout(id)
        $(this).removeData('timeout_id')
      $(this).fadeOut('fast')
    true


  _toast_element: ->
    if $('#toast').length == 0
      $(document.body).append $('<div>').attr('id', 'toast').hide().append("<div>")
    $('#toast div')

  toast: (text, class_name = 'notice') ->
    @_toast_element().each (idx, el) =>
      the_toast = $(el).parent()
      el.className = class_name
      el.innerHTML = text
      the_toast.fadeIn 'fast', ->
        id = setTimeout =>
            the_toast.fadeOut('fast')
          , 3000
        the_toast.data("timeout_id", id)

  _init_tooltips: ->
    $(document).tooltip
      items: "[data-tooltip]"
      track: true
      hide: false
      content: ->
        $(this).data('tooltip')




jQuery -> ( window.table_it = new TableIt )
