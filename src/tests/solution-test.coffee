solution = require "../solution"
expect = require('chai').expect
util = require "util"
debug = require("debug")("vsproj:tests:solution-test")

describe 'Solution', () ->
  it 'Open Simple', () ->
    sol = new solution()
    sol.open("./demo/solution.sln").then () ->
      expect(sol.VisualStudioVersion).to.equal("12.0.30501.0")

  it 'Save Simple', () ->
    sol = new solution()
    sol.open("./demo/solution.sln").then () ->
      debug "open completed", sol
      sol.save("./demo/solution-result.sln").then () ->
        expect(true).to.equal(true)
