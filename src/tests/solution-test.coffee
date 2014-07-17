vsProj = require "../index"
expect = require('chai').expect
util = require "util"

describe 'Solution', () ->
  it 'Open Simple', () ->
    vsProj.openSolution("./demo/WebApplication1.sln").then (sol) ->
      VisualStudioVersion = sol.getElement("VisualStudioVersion").properties[0]
      expect(VisualStudioVersion).to.equal("12.0.30501.0")
      #console.log "sol: ", util.inspect(sol)
      #debugger
  it 'Save Simple', () ->
    vsProj.openSolution("./demo/WebApplication1.sln").then (sol) ->

      sol.save("./demo/saved.sln").then () ->
        console.log "save done"
        expect(true).to.equal(true)
      #console.log "sol: ", util.inspect(sol)
      #debugger
