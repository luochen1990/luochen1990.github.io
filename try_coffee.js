// Generated by CoffeeScript 1.7.1
(function() {
  var init_coffee_editor, storage;

  init_coffee_editor = function(coffee_code_div, js_code_div) {
    var count_indent, tab, _compile, _eval, _js_code;
    $(coffee_code_div).css({
      'tab-size': '4',
      '-moz-tab-size': '4',
      '-o-tab-size': '4'
    });
    _js_code = '';
    _compile = function() {
      _js_code = CoffeeScript.compile($(coffee_code_div).val(), {
        bare: true
      });
      if (js_code_div) {
        $(js_code_div).val(_js_code);
      }
      return null;
    };
    _eval = function() {
      return eval(_js_code);
    };
    $(coffee_code_div).on('run', function() {
      _compile();
      return _eval();
    });
    count_indent = function(line, tab) {
      var c, i;
      c = 0;
      i = 0;
      while (i < line.length) {
        if (line.substr(i, tab.length) === tab) {
          c += 1;
          i += tab.length;
        } else {
          break;
        }
      }
      return c;
    };
    tab = '\t';
    $(coffee_code_div).on('keydown', function(e) {
      var after, before, c, cnt, end, i, indent, inserted, last_line, lines, selected, start, text, _i, _j, _ref, _ref1, _ref2;
      if ((_ref = e.keyCode) === 9 || _ref === 13 || _ref === 8) {
        e.preventDefault();
        text = this.value;
        start = this.selectionStart;
        end = this.selectionEnd;
        if (e.keyCode === 9 && start !== end) {
          while (start - 1 >= 0 && text[start - 1] !== '\n') {
            start -= 1;
          }
        }
        selected = text.slice(start, end);
        before = text.slice(0, start);
        after = text.slice(end);
        if (e.keyCode === 9) {
          if (start === end) {
            this.value = before + tab + after;
            this.selectionStart = this.selectionEnd = start + tab.length;
          } else {
            lines = selected.split('\n');
            cnt = 0;
            if (e.shiftKey) {
              for (i = _i = 0, _ref1 = lines.length; 0 <= _ref1 ? _i < _ref1 : _i > _ref1; i = 0 <= _ref1 ? ++_i : --_i) {
                if (lines[i].slice(0, tab.length) === tab) {
                  lines[i] = lines[i].slice(tab.length);
                  cnt -= tab.length;
                }
              }
            } else {
              for (i = _j = 0, _ref2 = lines.length; 0 <= _ref2 ? _j < _ref2 : _j > _ref2; i = 0 <= _ref2 ? ++_j : --_j) {
                lines[i] = tab + lines[i];
                cnt += tab.length;
              }
            }
            selected = lines.join('\n');
            this.value = before + selected + after;
            this.selectionStart = start;
            this.selectionEnd = end + cnt;
          }
        }
        if (e.keyCode === 8) {
          if (start === end) {
            c = before.slice(-tab.length) === tab ? tab.length : 1;
            this.value = before.slice(0, -c) + after;
            this.selectionStart = this.selectionEnd = start - c;
          } else {
            this.value = before + after;
            this.selectionStart = this.selectionEnd = start;
          }
        }
        if (e.keyCode === 13) {
          if (e.shiftKey || e.ctrlKey) {
            return $(coffee_code_div).trigger('run');
          } else {
            if (before.length === 0) {
              this.value = before + '\n' + after;
              return this.selectionStart = this.selectionEnd = start + 1;
            } else {
              lines = before.split('\n');
              last_line = lines[lines.length - 1];
              indent = count_indent(last_line, tab);
              if (/(^\s*(for|while|until|if|unless) )|((\(|\[|\{|[-=]>)$)/.test(last_line)) {
                indent += 1;
              }
              inserted = '\n' + tab.repeat(indent);
              this.value = before + inserted + after;
              return this.selectionStart = this.selectionEnd = start + inserted.length;
            }
          }
        }
      }
    });
    return {
      coffee_code: function(s) {
        if (s != null) {
          return $(coffee_code_div).val(s);
        } else {
          return $(coffee_code_div).val();
        }
      },
      js_code: function() {
        _compile();
        return _js_code;
      }
    };
  };

  storage = {
    read: function() {
      var _ref;
      return obj((_ref = localStorage.data) != null ? _ref : '{}');
    },
    write: function(data) {
      return localStorage.data = json(data);
    }
  };

  $(document).ready(function() {
    var data, editor, url, _i, _len, _ref;
    editor = init_coffee_editor('#code-block', '#js-block');
    data = location.search.uri_decode(obj).extend(storage.read(), {
      libs: [],
      code: ''
    });
    log(function() {
      return data.libs;
    });
    log(function() {
      return '\n' + data.code;
    });
    storage.write(data);
    _ref = data.libs;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      url = _ref[_i];
      $.getScript(url);
    }
    editor.coffee_code(data.code);
    $('#code-block').on('run', function() {
      data.code = editor.coffee_code();
      return storage.write(data);
    });
    $('#run-button').on('click', function() {
      return $('#code-block').trigger('run');
    });
    $('#load-lib-button').on('click', function() {
      url = $('#lib-to-load').val();
      data.libs = data.libs.concat([url]);
      storage.write(data);
      return $.getScript(url);
    });
    return $('#get-url').on('click', function() {
      data.code = editor.coffee_code();
      storage.write(data);
      return location.search = data.uri_encode(json);
    });
  });

}).call(this);

//# sourceMappingURL=try_coffee.map
