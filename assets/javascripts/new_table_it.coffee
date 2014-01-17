class TableIt
  constructor: ->
    @_init_time_add()
    @_init_toast()
    @_init_tooltips()
    @_init_new_issue()
    @_init_close_on_tick()
    @_init_toggle_sidebar()
    true

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