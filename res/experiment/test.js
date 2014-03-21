// Generated by CoffeeScript 1.7.1
(function() {
  var WAITING_SECONDS, computer_gen, disturbance_gen, err, log;

  WAITING_SECONDS = 0.5;

  log = function(it) {
    return console.log(JSON.stringify(it));
  };

  err = function(it) {
    return alert(JSON.stringify(it));
  };

  computer_gen = function(computer_type) {
    var computer0_gen, computer1_gen, computer2_gen;
    computer0_gen = function() {
      return function(user_input) {
        var ans;
        ans = Math.random() < 0.5 ? 0 : 1;
        return user_input === ans;
      };
    };
    computer1_gen = function() {
      var choice_cnt;
      choice_cnt = [0, 0];
      return function(user_input) {
        var ans;
        ans = Math.random() < 0.5 ? 0 : 1;
        choice_cnt[user_input] += 1;
        if (Math.abs(choice_cnt[0] - choice_cnt[1]) >= 2) {
          ans = choice_cnt[0] < choice_cnt[1] ? 0 : 1;
        }
        return user_input === ans;
      };
    };
    computer2_gen = function() {
      var success_cnt;
      success_cnt = [0, 0];
      return function(user_input) {
        var ans;
        ans = Math.random() < 0.5 ? 0 : 1;
        if (Math.abs(success_cnt[0] - success_cnt[1]) >= 1) {
          ans = success_cnt[0] < success_cnt[1] ? 0 : 1;
        }
        if (user_input === ans) {
          success_cnt[user_input] += 1;
        }
        return user_input === ans;
      };
    };
    return eval("computer" + computer_type + "_gen()");
  };

  disturbance_gen = function(disturbance_type) {
    var disturbance1_gen, disturbance2_gen, disturbance3_gen;
    disturbance1_gen = function() {
      return function(user_input) {
        if (Math.random() < 0.5) {
          return 0;
        } else {
          return 1;
        }
      };
    };
    disturbance2_gen = function() {
      var choice_cnt;
      choice_cnt = [0, 0];
      return function(user_input) {
        var ans;
        ans = Math.random() < 0.5 ? 0 : 1;
        choice_cnt[user_input] += 1;
        if (Math.abs(choice_cnt[0] - choice_cnt[1]) >= 1) {
          ans = choice_cnt[0] > choice_cnt[1] ? 0 : 1;
        }
        return ans;
      };
    };
    disturbance3_gen = function() {
      var choice_cnt;
      choice_cnt = [0, 0];
      return function(user_input) {
        var ans;
        ans = Math.random() < 0.5 ? 0 : 1;
        choice_cnt[user_input] += 1;
        if (Math.abs(choice_cnt[0] - choice_cnt[1]) >= 1) {
          ans = choice_cnt[0] < choice_cnt[1] ? 0 : 1;
        }
        return ans;
      };
    };
    return eval("disturbance" + disturbance_type + "_gen()");
  };

  $(document).on('game-started', function(ev, disturbance_type, computer_type, game_round) {
    var accept_input, after_got_user_input, computer, disturbance, id, on_cicle_click, on_keydown, result, round_start_time, _i, _len, _ref, _results;
    $('#game-finished-div').remove();
    $('#game-started-div').remove();
    $('body').append("<div id='game-started-div'>\n<svg xmlns='http://www.w3.org/2000/svg' version='1.1'>\n	<circle id='left-cicle' cx='30%' cy='50%' r='20%' stroke='white' stroke-width='1' fill='blue' />\n	<circle id='right-cicle' cx='70%' cy='50%' r='20%' stroke='white' stroke-width='1' fill='blue' />\n</svg>\n<div><span>分数</span><label id='score'>0</label></div>\n</div>");
    computer = computer_gen(computer_type);
    if (disturbance_type > 0) {
      disturbance = disturbance_gen(disturbance_type);
    }
    result = [];
    accept_input = true;
    round_start_time = new Date().getTime();
    log(disturbance_type);
    log(computer_type);
    log(game_round);
    if (disturbance_type > 0) {
      $(['#left-cicle', '#right-cicle'][Math.random() < 0.5 ? 0 : 1]).attr('fill', 'yellow');
    }
    after_got_user_input = function(user_input) {
      var feedback;
      if (accept_input) {
        feedback = computer(user_input);
        $('#score').text(Number($('#score').text()) + feedback);
        log(user_input);
        log(feedback);
        result.push({
          time: new Date().getTime() - round_start_time,
          answer: user_input,
          same: feedback
        });
        log(result);
        if (result.length === game_round) {
          $(document).trigger('game-finished', [result]);
        }
        $(['#left-cicle', '#right-cicle'][user_input]).attr('fill', feedback ? 'green' : 'red');
        accept_input = false;
        return setTimeout((function() {
          $('#left-cicle').attr('fill', 'blue');
          $('#right-cicle').attr('fill', 'blue');
          accept_input = true;
          round_start_time = new Date().getTime();
          if (disturbance_type > 0) {
            return $(['#left-cicle', '#right-cicle'][disturbance(user_input)]).attr('fill', 'yellow');
          }
        }), WAITING_SECONDS * 1000);
      }
    };
    on_cicle_click = function(ev) {
      return after_got_user_input({
        'left-cicle': 0,
        'right-cicle': 1
      }[ev.target.id]);
    };
    on_keydown = function(ev) {
      var char;
      char = typeof ev.which === 'number' ? ev.which : ev.keyCode;
      if (char === 37 || char === 39) {
        return after_got_user_input(char === 37 ? 0 : 1);
      }
    };
    document.onkeydown = on_keydown;
    _ref = ['#left-cicle', '#right-cicle'];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      id = _ref[_i];
      _results.push($(id).on('click', on_cicle_click));
    }
    return _results;
  });

  $(document).on('game-finished', function(ev, result) {
    var csv2href, download_href, json2csv, json2table, result_analysis;
    json2table = function(json) {
      var k, row, v;
      return "<table class='table table-striped'>\n<tr><th>" + (((function() {
        var _ref, _results;
        _ref = result[0];
        _results = [];
        for (k in _ref) {
          v = _ref[k];
          _results.push(k);
        }
        return _results;
      })()).join('</th><th>')) + "</th></tr>\n<tr><td>" + (((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = result.length; _i < _len; _i++) {
          row = result[_i];
          _results.push(((function() {
            var _results1;
            _results1 = [];
            for (k in row) {
              v = row[k];
              _results1.push(v);
            }
            return _results1;
          })()).join('</td><td>'));
        }
        return _results;
      })()).join('</td></tr><tr><td>')) + "</td></tr>\n</table>";
    };
    json2csv = function(json) {
      var k, row, v;
      return ((function() {
        var _ref, _results;
        _ref = result[0];
        _results = [];
        for (k in _ref) {
          v = _ref[k];
          _results.push(k);
        }
        return _results;
      })()).join(',') + '\n' + ((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = result.length; _i < _len; _i++) {
          row = result[_i];
          _results.push(((function() {
            var _results1;
            _results1 = [];
            for (k in row) {
              v = row[k];
              _results1.push(v);
            }
            return _results1;
          })()).join(','));
        }
        return _results;
      })()).join('\n');
    };
    csv2href = function(csv) {
      return "data:text/csv;charset=utf-8," + encodeURIComponent(csv);
    };
    result_analysis = function(result) {
      var cc, fc, i, r, sc, score, _i, _ref;
      cc = [0, 0];
      fc = [0, 0];
      sc = [0, 0];
      score = 0;
      for (i = _i = 0, _ref = result.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        r = result[i];
        cc[r.answer] += 1;
        if (i > 0 && r.answer === result[i - 1].answer ^ result[i - 1].same) {
          fc[r.answer] += 1;
        }
        if (r.same) {
          sc[r.answer] += 1;
        }
        score += r.same;
        result[i].score = score;
        result[i].left_choice_ratio = cc[0] / (i + 1);
        result[i].right_choice_ratio = cc[1] / (i + 1);
        result[i].left_follow_ratio = fc[0] / (i + 1);
        result[i].right_follow_ratio = fc[1] / (i + 1);
        result[i].left_success_ratio = sc[0] / (i + 1);
        result[i].right_success_ratio = sc[1] / (i + 1);
      }
      return result;
    };
    download_href = csv2href(json2csv(result_analysis(result)));
    $('#game-started-div').remove();
    return $('body').append("<div id='game-finished-div'>\n<a id='download-result' download='result.csv' href='" + download_href + "'>[保存实验记录]</a>\n" + (json2table(result_analysis(result))) + "\n</div>");
  });

  $(document).ready(function() {
    log('hello');
    $('body').append("<div id='game-select-div'>\n<input type='number' style='width:100px' id='disturbance_type' min='0' max='3' value='' placeholder='干扰算法ID' />\n<input type='number' style='width:100px' id='computer_type' min='0' max='2' value='' placeholder='机器算法ID' />\n<input type='number' style='width:100px' id='game_round' min='1' max='1000000' value='' placeholder='游戏轮数' />\n<input type='submit' style='width:100px' id='start-game' value='开始游戏' />\n</div>");
    return $('#start-game').on('click', function(ev) {
      return $(document).trigger('game-started', [Number($('#disturbance_type').val()), Number($('#computer_type').val()), Number($('#game_round').val())]);
    });
  });

}).call(this);
