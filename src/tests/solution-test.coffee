vsProj = require "../index"
expect = require('chai').expect
util = require "util"

describe 'Solution', () ->
  it 'Open', () ->
    vsProj.openSolution("./demo/WebApplication1.sln").then (sol) ->
      console.log util.inspect(sol)
      expect(sol.VisualStudioVersion).to.equal("12.0.30501.0")
