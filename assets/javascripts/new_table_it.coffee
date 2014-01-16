class TableIt
  constructor: ->
    @_init_time_add()
    @_init_toast()
    @_init_tooltips()
    @_init_new_issue()
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
      # headers:
      #   "X-Redmine-API-Key": @api_key
      data: 
        time: time
        # key: @api_key 
      complete: ->
        $(time_input).val('')

  _init_new_issue: ->
    $(document).on 'click', 'h2#new-issue', (event) ->
      event.preventDefault()
      $(this).next().slideToggle();

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