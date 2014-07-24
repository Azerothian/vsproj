fs = require "fs"
Promise = require "bluebird"

#Chains = require "chains"

util = require "util"
debug = require("debug")("vsproj:solution")
Element = require "./element"
slnfile = require "./slnfile"
map = require "coffeemapper"
path = require "path"

Project = require "./project"

elementProcessor = {
  newItem: () ->
    return new Element
  setValue: (item, key, value) ->
    item[key] = value
  getValue: (item, key) ->
    return item[key]
}

quoteString = (str) ->
  return "\"#{str}\""

cleanString = (str) ->
  return str.replace(/"/g, '').trim()

cleanPath = (str) ->
  if path.sep is '/'
    return str.replace /\\/g, '/'
  return str

projectDataMap = {
  read:
    "name": (src, resolve, reject) ->
      debug "projectDataMap.read.name"
      #console.log "src:", src
      resolve cleanString(src.properties[0])
    "path": (src, resolve, reject) ->
      debug "projectDataMap.read.path", src.properties[1]
      resolve cleanString(src.properties[1])
    "id": (src, resolve, reject) ->
      debug "projectDataMap.read.id"
      resolve cleanString(src.properties[2])
    "templateid": (src, resolve, reject) ->
      resolve src.args
    "innerElements": (src, resolve, reject) ->
      resolve src.elements
  write:
    "name": (src, resolve, reject) ->
      resolve "Project"
    "properties": (src, resolve, reject) ->
      debug "projectDataMap.write.properties", src
      resolve [quoteString(src.name), quoteString(src.path), quoteString(src.id)]
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

projectsMap = {
  read:
    "Projects": (src, resolve, reject) ->
      debug "projectsMap.read.Projects", src
      output = []
      promises = []
      func = (proj) ->
        return new Promise (resolve, reject) ->
          newProj = new Project()
          filePath = path.resolve(src.file, "../#{cleanPath(proj.path)}")
          debug "loading project", filePath
          newProj.open(filePath).then () ->
            newProj.name = proj.name
            resolve(newProj)
          , () ->
            debug "unable to load project", proj, src
            resolve()

      for p in src.ProjectData
        promises.push func(p)
      Promise.all(promises).then resolve, reject
}


elementMap = {
  read:
    "VisualStudioVersion": (src, resolve, reject) ->
      debug "elementMap.read.VisualStudioVersion"
      element = src.getElement("VisualStudioVersion")
      if element?
        return resolve(element.properties[0])
      return resolve("12.0.30501.0")

    "MinimumVisualStudioVersion": (src, resolve, reject) ->
      debug "elementMap.read.MinimumVisualStudioVersion"
      element = src.getElement("MinimumVisualStudioVersion")
      if element?
        return resolve(element.properties[0])
      return resolve("10.0.40219.1")
    "ProjectData": (src, resolve, reject) ->
      debug "elementMap.read.Projects"
      src.getElementsByName("Project").then (projects) ->
        debug "elementMap.read.Projects.getElementsByName.finish"
        map(projects, projectDataMap.read).then (data) ->
          debug "elementMap.read.Projects.map.finish"
          resolve(data)
        , reject
      , reject
    "Global": (src, resolve, reject) ->
      debug "Global start"
      src.getElementsByName("Global")
        .then resolve, reject
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
      #todo: generate ProjectDate from Projects
      map(src.ProjectData, projectDataMap.write, elementProcessor).then (result) ->
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
        @name = path.basename @file
        map(@slnfile, elementMap.read, null, @).then () =>
          map(@, projectsMap.read, null, @).then () =>
            resolve(@)
          , reject
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
