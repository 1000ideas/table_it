var MyPage;

MyPage = (function() {
  function MyPage() {
    this._init_click_task();
    this._init_stop_task();
    this._init_timer();
    true;
  }

  MyPage.prototype._init_click_task = function() {
    return $(document).find("table.issues tr[id^='issue']").click(function(e) {
      e.preventDefault();
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
    });
  };

  MyPage.prototype._init_stop_task = function() {
    return $(document).find('#stop-work').click(function() {
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

  MyPage.prototype.timer = function(previousTime, startTime) {
    var diff, hours, minutes, now, seconds;
    now = new Date();
    diff = now - startTime;
    seconds = Math.floor(diff / 1000) % 60;
    minutes = (Math.floor(diff / 1000 / 60) % 60) + previousTime.minutes;
    hours = (Math.floor(diff / 1000 / 60 / 60) % 24) + previousTime.hours;
    return $('#time-count').text(this.timeToString({
      hours: hours,
      minutes: minutes,
      seconds: seconds
    }));
  };

  MyPage.prototype.spentTimeHumanize = function() {
    var hours, minutes;
    hours = parseInt($('#mypage-task').data('time'), 10);
    minutes = parseFloat($('#mypage-task').data('time')) - hours;
    minutes = parseInt(minutes * 60);
    return {
      hours: hours,
      minutes: minutes
    };
  };

  MyPage.prototype.getStartTime = function() {
    var date;
    date = $('#mypage-task').data('startTime').split(' ');
    date = (date[0] + ' ' + date[1]).split(/[\- :]/);
    date[1] = (parseInt(date[1]) - 1).toString();
    return new Date(date[0], date[1], date[2], date[3], date[4], date[5], 0);
  };

  MyPage.prototype._init_timer = function() {
    var previousTime, startTime;
    previousTime = this.spentTimeHumanize();
    startTime = this.getStartTime();
    return setInterval((function(_this) {
      return function() {
        return _this.timer(previousTime, startTime);
      };
    })(this), 1000);
  };

  return MyPage;

})();

jQuery(function() {
  return window.my_page = new MyPage;
});