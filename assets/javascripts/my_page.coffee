class MyPage
  constructor: ->
    @_init_click_task()
    @_init_stop_task()
    @_init_timer()
    true

  _init_click_task: ->
    $("#list-left table.issues tr[id^='issue']").click (e) ->
      if e.target.tagName == 'A'
        return true
      else
        $.ajax
          type: 'GET'
          dataType: 'html'
          data:
            issue_id: $(this).attr('id').split('-')[1],
            start: true
          url: '/my/page'
          success: (data, textStatus, jqXHR) ->
            location.reload()

  _init_stop_task: ->
    $('#stop-work').click ->
      $.ajax
        type: 'GET'
        dataType: 'html'
        data:
          issue_id: $('#issue-id').text(),
          start: false
        url: '/my/page'
        success: (data, textStatus, jqXHR) ->
          window.tableItLeaveBlock = true
          location.reload()

  _init_timer: ->
    startTime = @getStartTime()
    setInterval =>
      @timer startTime
    , 1000

  timeToString: (time) ->
    time.hours = "0#{time.hours}" if time.hours < 10
    time.minutes = "0#{time.minutes}" if time.minutes < 10
    time.seconds = "0#{time.seconds}" if time.seconds < 10
    "#{time.hours}:#{time.minutes}:#{time.seconds}"

  timer: (startTime) ->
    now = new Date()
    diff = now - startTime
    seconds = Math.floor(diff / 1000) % 60
    minutes = (Math.floor(diff / 1000 / 60) % 60)
    hours = (Math.floor(diff / 1000 / 60 / 60) % 24)
    $('#time-count').text(@timeToString({hours: hours, minutes: minutes, seconds: seconds}))

  getStartTime: ->
    date = $('#mypage-task').data('startTime').split(' ')
    date = (date[0] + ' ' + date[1]).split(/[\- :]/)
    date[1] = (parseInt(date[1]) - 1).toString();
    new Date(date[0], date[1], date[2], date[3], date[4], date[5], 0)


jQuery -> ( window.my_page = new MyPage )
