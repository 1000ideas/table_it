var MyPage;

MyPage = (function() {
  function MyPage() {
    this._init_click_task();
    this._init_stop_task();
    this._init_timer();
    true;
  }

  MyPage.prototype._init_click_task = function() {
    return $("#list-left table.issues tr[id^='issue']").click(function(e) {
      if (e.target.tagName === 'A') {
        return true;
      } else {
        return $.ajax({
          type: 'GET',
          dataType: 'html',
          data: {
            issue_id: $(this).attr('id').split('-')[1],
            start: true
          },
          url: '/my/page',
          success: function(data, textStatus, jqXHR) {
            return location.reload();
          }
        });
      }
    });
  };

  MyPage.prototype._init_stop_task = function() {
    return $('#stop-work').click(function() {
      return $.ajax({
        type: 'GET',
        dataType: 'html',
        data: {
          issue_id: $('#issue-id').text(),
          start: false
        },
        url: '/my/page',
        success: function(data, textStatus, jqXHR) {
          return location.reload();
        }
      });
    });
  };

  MyPage.prototype._init_timer = function() {
    var startTime;
    startTime = this.getStartTime();
    return setInterval((function(_this) {
      return function() {
        return _this.timer(startTime);
      };
    })(this), 1000);
  };

  MyPage.prototype.timeToString = function(time) {
    if (time.hours < 10) {
      time.hours = "0" + time.hours;
    }
    if (time.minutes < 10) {
      time.minutes = "0" + time.minutes;
    }
    if (time.seconds < 10) {
      time.seconds = "0" + time.seconds;
    }
    return time.hours + ":" + time.minutes + ":" + time.seconds;
  };

  MyPage.prototype.timer = function(startTime) {
    var diff, hours, minutes, now, seconds;
    now = new Date();
    diff = now - startTime;
    seconds = Math.floor(diff / 1000) % 60;
    minutes = Math.floor(diff / 1000 / 60) % 60;
    hours = Math.floor(diff / 1000 / 60 / 60) % 24;
    return $('#time-count').text(this.timeToString({
      hours: hours,
      minutes: minutes,
      seconds: seconds
    }));
  };

  MyPage.prototype.getStartTime = function() {
    var date;
    date = $('#mypage-task').data('startTime').split(' ');
    date = (date[0] + ' ' + date[1]).split(/[\- :]/);
    date[1] = (parseInt(date[1]) - 1).toString();
    return new Date(date[0], date[1], date[2], date[3], date[4], date[5], 0);
  };

  return MyPage;

})();

jQuery(function() {
  return window.my_page = new MyPage;
});
