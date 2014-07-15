(function() {
  var Promise, Solution, fs, readline,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  fs = require("fs");

  Promise = require("bluebird");

  readline = require("readline");

  Solution = (function() {
    function Solution() {
      this.onReadLine = __bind(this.onReadLine, this);
      this.open = __bind(this.open, this);
    }

    Solution.prototype.open = function(file) {
      this.file = file;
      return new Promise((function(_this) {
        return function(resolve, reject) {
          var rd;
          rd = readline.createInterface({
            input: fs.createReadStream(_this.file),
            output: process.stdout,
            terminal: false
          });
          rd.on("line", _this.onReadLine);
          return rd.on("close", function() {
            return resolve(this.data);
          });
        };
      })(this));
    };

    Solution.prototype.onReadLine = function(line) {
      var arr, prop;
      arr = line.split('=');
      if (arr.length > 1) {
        prop = arr[0].trim();
        return this[prop] = arr[1].trim();
      }
    };

    return Solution;

  })();

  module.exports = Solution;

}).call(this);
