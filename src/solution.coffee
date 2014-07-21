fs = require "fs"
Promise = require "bluebird"

#Chains = require "chains"

util = require "util"
debug = require("debug")("vsproj:solution")
Element = require "./element"
slnfile = require "./slnfile"
map = require "coffeemapper"


elementProcessor = {
  newItem: () ->
    return new Element
  setValue: (item, key, value) ->
    item[key] = value
  getValue: (item, key) ->
    return item[key]
}

projectMap = {
  read:
    "name": (src, resolve, reject) ->
      debug "projectMap.read.name"
      #console.log "src:", src
      resolve src.properties[0]
    "path": (src, resolve, reject) ->
      debug "projectMap.read.path"
      resolve src.properties[1]
    "id": (src, resolve, reject) ->
      debug "projectMap.read.id"
      resolve src.properties[2]
    "templateid": (src, resolve, reject) ->
      resolve src.args
    "innerElements": (src, resolve, reject) ->
      resolve src.elements
  write:
    "name": (src, resolve, reject) ->
      resolve "Project"
    "properties": (src, resolve, reject) ->
      debug "projectMap.write.properties", src
      resolve [src.name, src.path, src.id]
    "hasProperties": (src, resolve, reject) ->
      resolve true
    "hasArgs":  (src, resolve, reject) ->
      resolve src.templateid?
    "args": (src, resolve, reject) ->
      resolve(src.templateid)
    "isGroup": (src, resolve, reject) ->
      resolve true
    "elements": (src, resolve, reject) ->
      resolve src.innerElements

}

debug "set element map"
elementMap = {
  read:
    "VisualStudioVersion": (src, resolve, reject) ->
      debug "elementMap.read.VisualStudioVersion"
      value = src.getElement("VisualStudioVersion").properties[0]
      return resolve value
    "MinimumVisualStudioVersion": (src, resolve, reject) ->
      debug "elementMap.read.MinimumVisualStudioVersion"
      value = src.getElement("MinimumVisualStudioVersion").properties[0]
      return resolve value
    "Projects": (src, resolve, reject) ->
      debug "elementMap.read.Projects"
      src.getElementsByName("Project").then (projects) ->
        debug "elementMap.read.Projects.getElementsByName.finish"
        map(projects, projectMap.read).then (data) ->
          debug "elementMap.read.Projects.map.finish"
          resolve(data)
        , reject
      , reject
    "Global": (src, resolve, reject) ->
      debug "Global start"
      src.getElementsByName("Global")
        .then (global) ->
          debug "Global end", global
          resolve(global)
  write:
    "elements": (src, resolve, reject) ->
      debug "elementMap.write.elements", src.VisualStudioVersion, src.MinimumVisualStudioVersion
      data = []
      data.push new Element {
        name: "VisualStudioVersion"
        properties: [src.VisualStudioVersion]
        hasProperties: true
      }
      data.push new Element {
        name: "MinimumVisualStudioVersion"
        properties: [src.MinimumVisualStudioVersion]
        hasProperties: true
      }
      map(src.Projects, projectMap.write, elementProcessor).then (result) ->
        debug "elementMap.write.elements.map.Projects"
        for r in result
          data.push r
        data = data.concat(src.Global)
        debug "elementmap.write.data"
        return resolve data
      , reject
}


class Solution

  open: (@file) =>
    return new Promise (resolve, reject) =>
      @slnfile = new slnfile()
      debug "slnfile start", @slnfile
      @slnfile.open(@file).then () =>
        debug "slnfile opened - starting map"
        map(@slnfile, elementMap.read, null, @).then resolve, reject
      , reject

  save: (path = @file) =>
    return new Promise (resolve, reject) =>
      #debug "save", path, @
      if !@slnfile?
        throw "has not opened an existing sln"
      map(@, elementMap.write, elementProcessor, @slnfile).then () =>
        debug "map complete - starting to save", path, @slnfile.elements
        @slnfile.save(path).then (file) ->
          debug "save complete"
          resolve(file)
        , reject


module.exports = Solution
