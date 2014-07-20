slnFile = require "../slnfile"
expect = require('chai').expect
util = require "util"
debug = require("debug")("vsproj:tests:slnfile-test")

describe 'SlnFile', () ->
  it 'Open Simple', () ->
    sol = new slnFile()
    sol.open("./demo/WebApplication1.sln").then () ->
      VisualStudioVersion = sol.getElement("VisualStudioVersion").properties[0]
      expect(VisualStudioVersion).to.equal("12.0.30501.0")

      #console.log "sol: ", util.inspect(sol)
      #debugger
###
  it 'Save Simple', () ->
    sol = new slnFile()
    sol.open("./demo/WebApplication1.sln").then () ->
      sol.save("./demo/slnfile-test.sln").then () ->
        debug "save done"
        expect(true).to.equal(true)
      #console.log "sol: ", util.inspect(sol)
      #debugger
###
