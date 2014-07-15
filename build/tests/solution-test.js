(function() {
  var expect, util, vsProj;

  vsProj = require("../index");

  expect = require('chai').expect;

  util = require("util");

  describe('Solution', function() {
    return it('Open', function() {
      return vsProj.openSolution("./demo/WebApplication1.sln").then(function(sol) {
        console.log(util.inspect(sol));
        return expect(sol.VisualStudioVersion).to.equal("12.0.30501.0");
      });
    });
  });

}).call(this);
