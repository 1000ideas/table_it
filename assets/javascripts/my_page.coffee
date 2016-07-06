class MyPage
  constructor: ->
    @_init_click_task()
    @_init_stop_task()
    @_init_timer()
    true

  _init_click_task: ->
    $(document).find("table.issues tr[id^='issue']").click ->
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
    $(document).find('#stop-work').click ->
      $.ajax
        type: 'GET'
        dataType: 'html'
        data:
          issue_id: $('#issue-id').text(),
          start: false
        url: '/my/page'
        success: (data, textStatus, jqXHR) ->
          location.reload()

  timer: (previousTime, startTime) ->
    now = new Date()
    diff = now - startTime
    seconds = Math.floor(diff / 1000) % 60
    minutes = (Math.floor(diff / 1000 / 60) % 60) + previousTime.minutes
    hours = (Math.floor(diff / 1000 / 60 / 60) % 24) + previousTime.hours
    $('#time-count').text(hours.toString() + ':' + minutes.toString() + ':' + seconds.toString())

  spentTimeHumanize: ->
    hours = parseInt($('#mypage-task').data('time'), 10)
    minutes = parseFloat($('#mypage-task').data('time')) - hours;
    minutes = parseInt(minutes * 60)
    {
      hours: hours,
      minutes: minutes
    }

  getStartTime: ->
    date = $('#mypage-task').data('startTime').split(' ')
    date = (date[0] + ' ' + date[1]).split(' :-')
    date[1] = (parseInt(date[1]) - 1).toString();
    new Date(date[0], date[1], date[2], date[3], date[4], date[5], 0)

  _init_timer: ->
    previousTime = @spentTimeHumanize()
    startTime = @getStartTime()
    setInterval => 
      @timer previousTime, startTime
    , 1000



jQuery -> ( window.my_page = new MyPage )
