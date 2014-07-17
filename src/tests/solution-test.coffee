vsProj = require "../index"
expect = require('chai').expect
util = require "util"

describe 'Solution', () ->
  it 'Open Simple', () ->
    vsProj.openSolution("./demo/WebApplication1.sln").then (sol) ->
      VisualStudioVersion = sol.getElement("VisualStudioVersion").properties
      expect(VisualStudioVersion).to.equal("12.0.30501.0")
      debugger
  it 'Open Comprehensive', () ->
    vsProj.openSolution("./demo/Comprehensive.sln").then (sol) ->
      #VisualStudioVersion = sol.getElement("VisualStudioVersion").properties
      #expect(VisualStudioVersion).to.equal("12.0.30501.0")
      debugger
