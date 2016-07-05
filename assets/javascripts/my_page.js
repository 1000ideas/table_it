(function() {

var MyPage;

MyPage = (function() {
  function MyPage() {
    this._init_click_task();
    this._init_stop_task();
    true;
  }

  MyPage.prototype._init_click_task = function() {
    return $(document).find("table.issues tr[id^='issue']").click(function() {
      return $.ajax({
        type: 'GET',
        dataType: 'html',
        data: {
          issue_id: $(this).attr('id').split('-')[1],
          start: true
        },
        url: '/my/page/manage',
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
        url: '/my/page/manage',
        success: function(data, textStatus, jqXHR) {
          return location.reload();
        }
      });
    });
  };

  return MyPage;

})();

jQuery(function() {
  return window.my_page = new MyPage;
});

}).call(this);
