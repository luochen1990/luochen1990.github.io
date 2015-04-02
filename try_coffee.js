// Generated by CoffeeScript 1.9.1
(function() {
  var _status, decode_hash, decode_search, editor, encode_hash, encode_search, filter_empty_item, init_coffee_editor, init_status, is_empty_item, set_code, set_libs, set_status, storage;

  init_coffee_editor = function(coffee_code_div, js_code_div) {
    var _compile, _eval, _js_code, count_indent, tab;
    $(coffee_code_div).css({
      'tab-size': '4',
      '-moz-tab-size': '4',
      '-o-tab-size': '4'
    });
    _js_code = '';
    _compile = function() {
      var e;
      try {
        _js_code = CoffeeScript.compile($(coffee_code_div).val(), {
          bare: true
        });
        if (js_code_div) {
          $(js_code_div).val(_js_code);
        }
      } catch (_error) {
        e = _error;
        alert(e);
        throw e;
      }
      return null;
    };
    _eval = function() {
      var _js_code_runner, e;
      try {
        _js_code_runner = eval("(function(){" + (_js_code.toString()) + "})");
        return _js_code_runner();
      } catch (_error) {
        e = _error;
        alert(e);
        throw e;
      }
    };
    $(coffee_code_div).on('run', function() {
      log.histories.splice(0, Infinity);
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
    $(coffee_code_div).on('keydown', function(e, data) {
      var after, before, c, cnt, end, i, indent, inserted, j, l, last_line, lines, ref, ref1, ref2, selected, start, text;
      if (e.originalEvent != null) {
        if ((ref = e.keyCode) === 9 || ref === 13 || ref === 8) {
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
                for (i = j = 0, ref1 = lines.length; 0 <= ref1 ? j < ref1 : j > ref1; i = 0 <= ref1 ? ++j : --j) {
                  if (lines[i].slice(0, tab.length) === tab) {
                    lines[i] = lines[i].slice(tab.length);
                    cnt -= tab.length;
                  }
                }
              } else {
                for (i = l = 0, ref2 = lines.length; 0 <= ref2 ? l < ref2 : l > ref2; i = 0 <= ref2 ? ++l : --l) {
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
              $(coffee_code_div).trigger('run');
            } else {
              if (before.length === 0) {
                this.value = before + '\n' + after;
                this.selectionStart = this.selectionEnd = start + 1;
              } else {
                lines = before.split('\n');
                last_line = lines[lines.length - 1];
                indent = count_indent(last_line, tab);
                if (/(^\s*(for|while|until|if|unless) )|((\(|\[|\{|[-=]>)$)/.test(last_line)) {
                  indent += 1;
                }
                inserted = '\n' + tab.repeat(indent);
                this.value = before + inserted + after;
                this.selectionStart = this.selectionEnd = start + inserted.length;
              }
            }
          }
        }
      } else {
        text = this.value;
        start = this.selectionStart;
        end = this.selectionEnd;
        selected = text.slice(start, end);
        before = text.slice(0, start);
        after = text.slice(end);
        this.value = before + data.char + after;
        this.selectionStart = this.selectionEnd = start + data.char.length;
        this.focus();
      }
      return true;
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
      var ref;
      return obj((ref = localStorage.data) != null ? ref : '{}');
    },
    write: function(data) {
      return localStorage.data = json(data);
    }
  };

  is_empty_item = function(it) {
    if (it == null) {
      return true;
    }
    if (it instanceof Array && it.length === 0) {
      return true;
    }
    if (typeof it === 'string' && it.length === 0) {
      return true;
    }
    return false;
  };

  filter_empty_item = function(d) {
    var k, r, v;
    r = {};
    for (k in d) {
      v = d[k];
      if (!is_empty_item(v)) {
        r[k] = v;
      }
    }
    return r;
  };

  decode_search = uri_decoder(obj);

  encode_search = uri_encoder(json);

  decode_hash = function(b64) {
    return decodeURIComponent(escape(atob(b64)));
  };

  encode_hash = function(s) {
    return btoa(unescape(encodeURIComponent(s)));
  };

  editor = null;

  _status = {};

  init_status = function() {
    var code, j, len, libs, ref, ref1, ref2, results, url;
    ref = decode_search(location.search), libs = ref.libs, code = ref.code;
    _status = {
      libs: libs != null ? libs : [],
      code: (ref1 = decode_hash(location.hash.slice(1)) || code) != null ? ref1 : "log -> 'hello, coffee-mate!'"
    };
    log(function() {
      return _status;
    });
    if (_status.code != null) {
      location.hash = encode_hash(_status.code);
      location.search = _status.libs.length > 0 ? encode_search({
        libs: _status.libs
      }) : '';
    }
    editor.coffee_code(_status.code);
    console.log('libs: ', _status.libs);
    ref2 = _status.libs;
    results = [];
    for (j = 0, len = ref2.length; j < len; j++) {
      url = ref2[j];
      results.push($.getScript(url));
    }
    return results;
  };

  set_status = function(d) {
    var ref;
    _status = {
      libs: (ref = d.libs) != null ? ref : [],
      code: d.code
    };
    location.hash = encode_hash(_status.code);
    return location.search = _status.libs.length > 0 ? encode_search({
      libs: _status.libs
    }) : '';
  };

  set_libs = function(libs) {
    _status.libs = libs != null ? libs : [];
    return location.search = _status.libs.length > 0 ? encode_search({
      libs: _status.libs
    }) : '';
  };

  set_code = function(code) {
    _status.code = code != null ? code : '';
    return location.hash = encode_hash(_status.code);
  };

  log(function() {
    return navigator.userAgent;
  });

  $(document).ready(function() {
    var keys;
    editor = init_coffee_editor('#code-block', '#js-block');
    init_status();
    $(window).on('hashchange', function() {
      _status.code = decode_hash(location.hash.slice(1));
      editor.coffee_code(_status.code);
      return $('#code-block').trigger('run');
    });
    if (/Mobile/.test(navigator.userAgent)) {
      keys = [['tab', '\t'], ['cr', '\n'], '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '_', '=', '+', '\\', '|', '`', '~', '[', ']', ';', ':', '{', '}', '\\', '"', ',', '<', '<', '.', '/', '?'];
      foreach(enumerate(keys), function(arg) {
        var i, kb, key, keyname, keyvalue, ref;
        i = arg[0], key = arg[1];
        kb = $("#keyboard-part-" + (Math.floor(i / 12)));
        if (typeof key === 'string') {
          ref = [key, key], keyname = ref[0], keyvalue = ref[1];
        } else {
          keyname = key[0], keyvalue = key[1];
        }
        kb.append("<button id=\"key-" + i + "\">" + keyname + "</button>");
        return $("#key-" + i).on('click', function(e) {
          e.preventDefault();
          return $('#code-block').trigger('keydown', {
            char: keyvalue
          });
        });
      });
      $("#virtual-keyboard").css({
        display: 'block'
      });
    }
    $('#code-block').on('run', function() {
      set_code(editor.coffee_code());
      storage.write(_status);
      return $('#output-area').val(log.histories.map(function(xs) {
        return xs.join(' ');
      }).join('\n'));
    });
    $('#run-button').on('click', function() {
      return $('#code-block').trigger('run');
    });
    $('#load-lib-button').on('click', function() {
      var url;
      url = $('#lib-to-load').val();
      set_libs(_status.libs.concat([url]));
      storage.write(_status);
      return $.getScript(url);
    });
    $('#show-js-button').on('click', function() {
      if ($('#js-block').css('display') === 'none') {
        return $('#js-block').css({
          'display': 'inline-block'
        });
      } else {
        return $('#js-block').css({
          'display': 'none'
        });
      }
    });
    return $('#download-code').on('click', function() {
      return $('#download-code').attr({
        href: "data:text/coffeescript;base64," + (btoa(_status.code))
      });
    });
  });

  window.onload = function() {
    return $('#code-block').trigger('run');
  };

}).call(this);

//# sourceMappingURL=try_coffee.js.map
