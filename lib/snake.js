// Generated by CoffeeScript 1.6.2
/*

js 贪吃蛇 ai 演示
单个用户的 求解 情况
*/


(function() {
  var $, DIRECT_DOWN, DIRECT_LEFT, DIRECT_RIGHT, DIRECT_UP, log,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  $ = this.jQuery;

  DIRECT_UP = 'up';

  DIRECT_DOWN = 'down';

  DIRECT_RIGHT = 'right';

  DIRECT_LEFT = 'left';

  log = function(msg, tag) {
    if (tag == null) {
      tag = '';
    }
    return console.log(tag + ' ' + JSON.stringify(msg));
  };

  this.SnakeView = (function() {
    function SnakeView(div, width, height) {
      var row, t, x, y, _i, _j, _len, _ref, _ref1;

      this.div = div;
      this.width = width != null ? width : 100;
      this.height = height != null ? height : 100;
      this.startx = this.width >> 1;
      this.starty = this.height >> 1;
      this.direct = DIRECT_UP;
      this.tick_time = 10;
      this.body = [[this.startx, this.starty], [this.startx, this.starty + 1]];
      this.black = [-1, -1];
      this.foods = [-1, -1];
      this.null_cell = [];
      this.keys = [];
      this.map = [];
      for (y = _i = 0, _ref = this.height - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; y = 0 <= _ref ? ++_i : --_i) {
        t = (function() {
          var _j, _ref1, _results;

          _results = [];
          for (x = _j = 0, _ref1 = this.width - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
            _results.push(0);
          }
          return _results;
        }).call(this);
        this.map.push(t);
      }
      _ref1 = this.body;
      for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
        row = _ref1[_j];
        this.map[row[1]][row[0]] = 1;
      }
      this.ai = new Ai(this);
    }

    SnakeView.prototype.run = function() {
      var div, h, height, i, j, w, width, _i, _j, _ref, _ref1,
        _this = this;

      this.div.css({
        'position': 'relative',
        'border': '0px solid green',
        'background-color': '#000000'
      });
      width = this.div.width();
      height = this.div.height();
      w = (width - 1) / this.width - 1;
      h = (height - 1) / this.height - 1;
      for (i = _i = 0, _ref = this.height - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        for (j = _j = 0, _ref1 = this.width - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
          div = $("<div style='overflow:hidden;font-size:10px' id='id" + j + "x" + i + "' title='" + j + "x" + i + "'><span id='s" + j + "x" + i + "'  style='position:relative;top:10px;left:-10px;color:red;display:none;'>1</span></div>").css({
            'float': 'left',
            'background-color': '#000000',
            'margin-left': '1px',
            'margin-bottom': '1px',
            'width': w + 'px',
            'height': h + 'px'
          });
          $(this.div).append(div);
        }
      }
      div = $('<div style="background-color:#ffffff;color:red;position:absolute;width:100px;height:30px;text-align:center"></div>');
      div.css('left', (this.div.width() - div.width()) / 2);
      div.css('top', (this.div.height() - div.height()) / 2);
      div.hide();
      this.div.append(div);
      this.msg = div;
      $(window).keydown(function(e) {
        var direct;

        if (e.keyCode === 37) {
          direct = DIRECT_LEFT;
          _this.keys.push(direct);
          return false;
        }
        if (e.keyCode === 39) {
          direct = DIRECT_RIGHT;
          _this.keys.push(direct);
          return false;
        }
        if (e.keyCode === 38) {
          direct = DIRECT_UP;
          _this.keys.push(direct);
          return false;
        }
        if (e.keyCode === 40) {
          direct = DIRECT_DOWN;
          _this.keys.push(direct);
          return false;
        }
        if (e.keyCode === 32) {
          if (_this.t > 0) {
            window.clearInterval(_this.t);
            _this.t = 0;
          } else {
            _this.t = window.setInterval(function() {
              return _this.tick();
            }, _this.tick_time);
          }
        }
        return log('@direct' + _this.direct);
      });
      this.food();
      this.t = window.setInterval(function() {
        return _this.tick();
      }, this.tick_time);
      this.upview();
      return log('init done');
    };

    SnakeView.prototype.upview = function() {
      var j, row, x, y, _i, _j, _len, _ref, _ref1, _results;

      j = 0;
      _ref = this.body;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        row = _ref[_i];
        j++;
        if (j === 1) {
          this.show(row[0], row[1], 8);
        } else {
          this.show(row[0], row[1], 1);
        }
      }
      if (this.foods[0] > -1) {
        this.show(this.foods[0], this.foods[1], 2);
      }
      if (this.black[0] > -1) {
        this.show(this.black[0], this.black[1], 0);
        this.black[0] = -1;
        this.black[1] = -1;
      }
      _results = [];
      for (y = _j = 0, _ref1 = this.height - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
        _results.push((function() {
          var _k, _ref2, _results1;

          _results1 = [];
          for (x = _k = 0, _ref2 = this.width - 1; 0 <= _ref2 ? _k <= _ref2 : _k >= _ref2; x = 0 <= _ref2 ? ++_k : --_k) {
            _results1.push($('#s' + x + 'x' + y).html(this.map[y][x]));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    SnakeView.prototype.show = function(x, y, v) {
      if (v === 1) {
        $('#id' + x + 'x' + y).css('background-color', '#ffffff');
      }
      if (v === 2) {
        $('#id' + x + 'x' + y).css('background-color', '#aaffaa');
      }
      if (v === 8) {
        $('#id' + x + 'x' + y).css('background-color', '#ffaaaa');
      }
      if (v === 0) {
        $('#id' + x + 'x' + y).css('background-color', '#000000');
      }
      return this.map[y][x] = v;
    };

    SnakeView.prototype.gameover = function(v) {
      if (v == null) {
        v = 0;
      }
      window.clearInterval(this.t);
      if (v === 0) {
        this.msg.html('game over!').show();
      }
      if (v === 1) {
        return this.msg.html('you win!').show();
      }
    };

    SnakeView.prototype.food = function() {
      var ok, sel, x, y, _i, _j, _ref, _ref1;

      ok = [];
      for (y = _i = 0, _ref = this.height - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; y = 0 <= _ref ? ++_i : --_i) {
        for (x = _j = 0, _ref1 = this.width - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
          if (this.map[y][x] === 0) {
            ok[ok.length] = [x, y];
          }
        }
      }
      if (ok.length === 0) {
        log("your win!");
        return this.gameover(1);
      }
      sel = parseInt(Math.random() * ok.length);
      this.foods[0] = ok[sel][0];
      return this.foods[1] = ok[sel][1];
    };

    SnakeView.prototype.move = function(row) {
      var head, t, _ref, _ref1, _ref2;

      if (this.foods[0] === row[0] && this.foods[1] === row[1]) {
        this.food();
        [].splice.apply(this.body, [0, 1].concat(_ref = [row.slice(0), this.body[0]])), _ref;
        return this.map[row[1]][row[0]] = 1;
      } else {
        head = this.body[0];
        if (this.map[row[1]][row[0]] > 0) {
          return this.gameover();
        }
        if (head) {
          [].splice.apply(this.body, [0, 1].concat(_ref1 = [row.slice(0), head])), _ref1;
        } else {
          [].splice.apply(this.body, [0, 1].concat(_ref2 = [row.slice(0)])), _ref2;
        }
        this.map[row[1]][row[0]] = 1;
        t = this.body.pop();
        if (t) {
          return this.show(t[0], t[1], 0);
        }
      }
    };

    SnakeView.prototype.step = function(row, direct) {
      if (direct === DIRECT_UP) {
        row[1]--;
        if (row[1] < 0) {
          return false;
        }
      }
      if (direct === DIRECT_DOWN) {
        row[1]++;
        if (row[1] >= this.height) {
          return false;
        }
      }
      if (direct === DIRECT_LEFT) {
        row[0]--;
        if (row[0] < 0) {
          return false;
        }
      }
      if (direct === DIRECT_RIGHT) {
        row[0]++;
        if (row[0] >= this.width) {
          return false;
        }
      }
      return row;
    };

    SnakeView.prototype.tick = function() {
      var row, row2, _i, _len, _ref, _ref1;

      this.upview();
      this.ai.tick();
      if (this.keys.length > 0) {
        this.direct = this.keys[0];
        [].splice.apply(this.keys, [0, 1].concat(_ref = [])), _ref;
      }
      _ref1 = this.body;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        row = _ref1[_i];
        row = [row[0], row[1]];
        row2 = this.step(row, this.direct);
        if (row2 === false) {
          return this.gameover();
        }
        this.move(row2);
        break;
      }
      return this.upview();
    };

    return SnakeView;

  })();

  this.Ai = (function() {
    function Ai(game) {
      this.game = game;
      this.count_len = __bind(this.count_len, this);
      this.state = 0;
    }

    Ai.prototype.tick = function() {
      return this.slow_ai();
    };

    Ai.prototype.slow_ai = function() {
      /*
      复杂的ai
      按照一定的策略行走即可
      首先 走到 顶部
      在顺时针走到下边,右下角,左下角,在到左上角之后开始排开绕
      使用最简单的策略,还可以在优化
      */

      var head, i, x, _i, _j, _k, _l, _m, _n, _o, _p, _q, _r, _ref, _ref1, _ref10, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9, _s;

      if (this.state === 0) {
        /*调整状态
        调整沿一边走的状态
        */

        head = this.game.body[0];
        for (i = _i = 0, _ref = head[1] - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          this.game.keys.push(DIRECT_UP);
        }
        for (i = _j = 0, _ref1 = this.game.width - head[0] - 2; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          this.game.keys.push(DIRECT_RIGHT);
        }
        for (i = _k = 0, _ref2 = this.game.height - 2; 0 <= _ref2 ? _k <= _ref2 : _k >= _ref2; i = 0 <= _ref2 ? ++_k : --_k) {
          this.game.keys.push(DIRECT_DOWN);
        }
        for (i = _l = 0, _ref3 = this.game.width - 2; 0 <= _ref3 ? _l <= _ref3 : _l >= _ref3; i = 0 <= _ref3 ? ++_l : --_l) {
          this.game.keys.push(DIRECT_LEFT);
        }
        for (i = _m = 0, _ref4 = this.game.height - 2; 0 <= _ref4 ? _m <= _ref4 : _m >= _ref4; i = 0 <= _ref4 ? ++_m : --_m) {
          this.game.keys.push(DIRECT_UP);
        }
        this.state = 1;
        return;
      }
      if (this.state === 1) {
        if (this.game.keys.length === 0) {
          this.state = 2;
        }
      }
      if (this.state === 2) {
        for (x = _n = 0, _ref5 = ((this.game.width - 2) >> 1) - 1; 0 <= _ref5 ? _n <= _ref5 : _n >= _ref5; x = 0 <= _ref5 ? ++_n : --_n) {
          this.game.keys.push(DIRECT_RIGHT);
          for (i = _o = 0, _ref6 = this.game.height - 3; 0 <= _ref6 ? _o <= _ref6 : _o >= _ref6; i = 0 <= _ref6 ? ++_o : --_o) {
            this.game.keys.push(DIRECT_DOWN);
          }
          this.game.keys.push(DIRECT_RIGHT);
          for (i = _p = 0, _ref7 = this.game.height - 3; 0 <= _ref7 ? _p <= _ref7 : _p >= _ref7; i = 0 <= _ref7 ? ++_p : --_p) {
            this.game.keys.push(DIRECT_UP);
          }
        }
        this.state = 3;
      }
      if (this.state === 3) {
        if (this.game.keys.length === 0) {
          this.state = 4;
        }
      }
      if (this.state === 4) {
        this.game.keys.push(DIRECT_RIGHT);
        for (i = _q = 0, _ref8 = this.game.height - 2; 0 <= _ref8 ? _q <= _ref8 : _q >= _ref8; i = 0 <= _ref8 ? ++_q : --_q) {
          this.game.keys.push(DIRECT_DOWN);
        }
        for (i = _r = 0, _ref9 = this.game.width - 2; 0 <= _ref9 ? _r <= _ref9 : _r >= _ref9; i = 0 <= _ref9 ? ++_r : --_r) {
          this.game.keys.push(DIRECT_LEFT);
        }
        for (i = _s = 0, _ref10 = this.game.height - 2; 0 <= _ref10 ? _s <= _ref10 : _s >= _ref10; i = 0 <= _ref10 ? ++_s : --_s) {
          this.game.keys.push(DIRECT_UP);
        }
        this.state = 5;
        return;
      }
      if (this.state === 5) {
        if (this.game.keys.length === 1) {
          return this.state = 1;
        }
      }
    };

    Ai.prototype.simple_ai = function() {
      var cur_dir, head, len, min_dir, min_len, ok_dir, ok_dir2, result, test_v, _i, _len;

      this.game.keys.length = 0;
      head = this.game.body[0];
      ok_dir = this.find_ok_dir(this.game.body);
      min_len = 99999999;
      min_dir = {};
      ok_dir2 = [];
      for (_i = 0, _len = ok_dir.length; _i < _len; _i++) {
        cur_dir = ok_dir[_i];
        result = this.game.step(head.slice(0), cur_dir);
        if (result !== false) {
          test_v = this.game.map[result[1]][result[0]];
          if (test_v !== 2 && test_v !== 0) {
            continue;
          }
          len = this.count_len(result, this.game.foods);
          if (len <= min_len) {
            min_len = len;
            if (!min_dir[len]) {
              min_dir[len] = [];
            }
            min_dir[len].push(cur_dir);
          }
          ok_dir2[ok_dir2.length] = cur_dir;
        }
      }
      if (ok_dir2.length === 0) {
        log('no choice');
        return this.game.gameover();
      }
      return this.game.direct = min_dir[min_len][0];
    };

    Ai.prototype.count_len = function(p1, p2) {
      var len;

      len = (p1[0] - p2[0]) * (p1[0] - p2[0]) + (p1[1] - p2[1]) * (p1[1] - p2[1]);
      return len;
    };

    Ai.prototype.find_ok_dir = function(body) {
      if (body.length === 1) {
        return [DIRECT_UP, DIRECT_DOWN, DIRECT_LEFT, DIRECT_RIGHT];
      }
      if (body.length > 1) {
        if (body[0][0] === body[1][0]) {
          if (body[0][1] > body[1][1]) {
            return [DIRECT_DOWN, DIRECT_LEFT, DIRECT_RIGHT];
          } else {
            return [DIRECT_UP, DIRECT_LEFT, DIRECT_RIGHT];
          }
        }
        if (body[0][1] === body[1][1]) {
          if (body[0][0] > body[1][0]) {
            return [DIRECT_UP, DIRECT_DOWN, DIRECT_RIGHT];
          } else {
            return [DIRECT_UP, DIRECT_DOWN, DIRECT_LEFT];
          }
        }
      }
    };

    return Ai;

  })();

}).call(this);