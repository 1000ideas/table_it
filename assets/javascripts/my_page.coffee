class MyPage
  constructor: ->
    @_init_click_task()
    @_init_stop_task()
    true

  _init_click_task: ->
    $(document).find("table.issues tr[id^='issue']").click ->
      $.ajax
        type: 'GET'
        dataType: 'html'
        data:
          issue_id: $(this).attr('id').split('-')[1],
          start: true
        url: '/my/page/manage'
        success: (data, textStatus, jqXHR) ->
          location.reload()

  _init_stop_task: ->
    $(document).find('#stop-work').click ->
      $.ajax
        type: 'GET'
        dataType: 'html'
        data:
          issue_id: $('#issue-id').text(),
          start: false
        url: '/my/page/manage'
        success: (data, textStatus, jqXHR) ->
          location.reload()


jQuery -> ( window.my_page = new MyPage )
