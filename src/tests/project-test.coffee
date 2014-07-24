project = require "../project"
expect = require('chai').expect
util = require "util"
debug = require("debug")("vsproj:tests:project-test")

describe 'Project', () ->
  it 'Open', () ->
    proj = new project()
    proj.open("./demo/TestWebApplication/TestWebApplication.csproj").then () ->
      #debug "project inspect", proj
      expect(true).to.equal(true)
