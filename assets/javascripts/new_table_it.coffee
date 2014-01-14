class TableIt
  constructor: ->
    true

  _toast_element: ->
    if $('#toast').length == 0
      $(document.body).append $('<div>').attr('id', 'toast').hide().append("<div>")
    $('#toast div')

  toast: (text, class_name = 'notice') ->
    @_toast_element().each (idx, el) =>
      el.className = class_name
      el.innerHTML = text
      $(el).parent().fadeIn 'fast', ->
        setTimeout => 
            $(el).parent().fadeOut('fast')
          , 3000




jQuery -> ( window.table_it = new TableIt )