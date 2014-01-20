// Generated by CoffeeScript 1.6.3
(function() {
  var TableIt;

  TableIt = (function() {
    TableIt.refresh_time = 60;

    function TableIt() {
      this._init_time_add();
      this._init_toast();
      this._init_tooltips();
      this._init_new_issue();
      this._init_close_on_tick();
      this._init_toggle_sidebar();
      this._init_auto_refresh();
      true;
    }

    TableIt.prototype.refresh = function(done) {
      var _this = this;
      if (done == null) {
        done = (function() {
          return _this._reset_auto_refresh();
        });
      }
      return $.ajax({
        url: location.href,
        dataType: 'html',
        success: function(data) {
          return $("#issues-list-form").replaceWith($(data).filter("#issues-list-form"));
        },
        complete: done
      });
    };

    TableIt.prototype.set_api_key = function(key) {
      return this.api_key = key;
    };

    TableIt.prototype.add_time = function(time_input) {
      var time, url;
      time = $(time_input).val();
      url = $(time_input).data('url');
      if (time.length === 0 || (url == null)) {
        return;
      }
      return $.ajax({
        dataType: 'script',
        type: 'POST',
        url: url,
        data: {
          time: time
        },
        complete: function() {
          return $(time_input).val('');
        }
      });
    };

    TableIt.prototype.set_cookie = function(name, value, days) {
      var d;
      if (days == null) {
        days = 1;
      }
      d = new Date();
      d.setTime(d.getTime() + days * 24 * 60 * 60 * 1000);
      return document.cookie = "" + name + "=" + value + "; expires=" + (d.toGMTString());
    };

    TableIt.prototype._init_auto_refresh = function() {
      var _this = this;
      return this.refresh_timeout_id = setTimeout(function() {
        return _this.refresh(function() {
          return _this._init_auto_refresh();
        });
      }, TableIt.refresh_time * 1000);
    };

    TableIt.prototype._clear_auto_refresh = function() {
      return clearTimeout(this.refresh_timeout_id);
    };

    TableIt.prototype._reset_auto_refresh = function() {
      this._clear_auto_refresh();
      return this._init_auto_refresh();
    };

    TableIt.prototype._init_toggle_sidebar = function() {
      var status,
        _this = this;
      status = document.cookie.match(/sidebar=(open|closed)(?:;|$)/);
      if (status != null) {
        $('#main').toggleClass('nosidebar', status[1] === 'closed');
      }
      return $(document).on('click', '#toggle-sidebar', function(event) {
        var closed;
        event.preventDefault();
        closed = $(event.target).parents('#main').toggleClass('nosidebar').hasClass('nosidebar');
        return _this.set_cookie('sidebar', (closed ? "closed" : "open"), 365);
      });
    };

    TableIt.prototype._init_close_on_tick = function() {
      return $(document).on('click', '.issues td.checkbox input[type=checkbox]', function(event) {
        var checked, closed, url;
        event.preventDefault;
        checked = $(this).is(':checked');
        closed = $(this).parents('tr.closed').length > 0;
        url = $(this).data('url');
        if (checked !== closed) {
          return $.ajax({
            dataType: 'script',
            type: 'POST',
            url: url
          });
        }
      });
    };

    TableIt.prototype._init_new_issue = function() {
      var _this = this;
      $(document).on('click', 'h2#new-issue', function(event) {
        event.preventDefault();
        return $(this).next().slideToggle('fast');
      });
      $(document).on('change', '.home-new-issue-form #issue_project_id', function(event) {
        return $.ajax({
          dataType: 'script',
          type: 'GET',
          data: {
            project_id: $(this).val()
          },
          url: $(this).data('url'),
          error: function() {
            return $('.home-new-issue-form #issue_assigned_to_id').html($('<option>'));
          }
        });
      });
      $(document).on('ajax:success', 'form.home-new-issue-form', function(event, data) {
        var label, _ref;
        label = (_ref = $(event.target).data('success')) != null ? _ref : "Success";
        _this.toast(label, 'notice');
        _this.refresh();
        return $('#issue_subject, #issue_description', event.target).each(function(idx, el) {
          return $(el).val('');
        });
      });
      return $(document).on('ajax:error', 'form.home-new-issue-form', function(event, xhr, status, error) {
        var rsp;
        rsp = JSON.parse(xhr.responseText);
        if ((rsp.errors != null) && rsp.errors.length > 0) {
          return _this.toast(rsp.errors[0], 'alert');
        }
      });
    };

    TableIt.prototype._init_time_add = function() {
      var _this = this;
      $(document).on('click', '.add-time-button', function(event) {
        event.preventDefault();
        return _this.add_time($(event.target).prev());
      });
      $(document).on('keyup', '.add-time-input', function(event) {
        if (event.keyCode === 13) {
          event.preventDefault();
          return _this.add_time(event.target);
        }
      });
      return true;
    };

    TableIt.prototype._init_toast = function() {
      this._toast_element();
      $(document).on('click', '#toast', function() {
        var id;
        id = $(this).data('timeout_id');
        if (id != null) {
          clearTimeout(id);
          $(this).removeData('timeout_id');
        }
        return $(this).fadeOut('fast');
      });
      return true;
    };

    TableIt.prototype._toast_element = function() {
      if ($('#toast').length === 0) {
        $(document.body).append($('<div>').attr('id', 'toast').hide().append("<div>"));
      }
      return $('#toast div');
    };

    TableIt.prototype.toast = function(text, class_name) {
      var _this = this;
      if (class_name == null) {
        class_name = 'notice';
      }
      return this._toast_element().each(function(idx, el) {
        var the_toast;
        the_toast = $(el).parent();
        el.className = class_name;
        el.innerHTML = text;
        return the_toast.fadeIn('fast', function() {
          var id,
            _this = this;
          id = setTimeout(function() {
            return the_toast.fadeOut('fast');
          }, 3000);
          return the_toast.data("timeout_id", id);
        });
      });
    };

    TableIt.prototype._init_tooltips = function() {
      return $(document).tooltip({
        items: "[data-tooltip]",
        track: true,
        hide: false,
        content: function() {
          return $(this).data('tooltip');
        }
      });
    };

    return TableIt;

  })();

  jQuery(function() {
    return window.table_it = new TableIt;
  });

}).call(this);
