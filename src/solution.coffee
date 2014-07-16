fs = require "fs"
Promise = require "bluebird"
Chains = require "./chains"
util = require "util"

Element = require "./element"

newline = "\r\n"


class Solution
  open: (@file) =>
    return new Promise (resolve, reject) =>
      @list = []

      @elements = []
      @current = ""
      @groupLevel = 0

      fs.readFile @file, "utf8", (err, @fileData) =>
        if err?
          throw err

        lines = @fileData.split newline
        promises = new Chains
        for line in lines
          l = line.replace(/\t/g, '').trim()
          if l != "" and l.indexOf("#") != 0 and l.indexOf("Microsoft Visual Studio Solution File") != 0
            promises.push @render, @, [l]
        console.log "fireing chains"
        return promises.run().then () =>

          console.log "fin"
          #console.log "elements", util.inspect(@elements)
          resolve()
        , reject

  propertiesProcessor: () =>
    return new Promise (resolve, reject) =>

      #@VisualSudioVersion = @fileData.match(/^VisualStudioVersion = (.*)\s/gm)[0]


module.exports = Solution


###




class Solution extends Element
  open: (@file) =>
    return new Promise (resolve, reject) =>
      @list = []

      @elements = []
      @current = ""
      @groupLevel = 0

      fs.readFile @file, "utf8", (err, @fileData) =>
        if err?
          throw err

        lines = @fileData.split newline
        promises = new Chains
        for line in lines
          l = line.replace(/\t/g, '').trim()
          if l != "" and l.indexOf("#") != 0 and l.indexOf("Microsoft Visual Studio Solution File") != 0
            promises.push @render, @, [l]
        console.log "fireing chains"
        return promises.run().then () =>

          for e in @elements
            if e.isGroup
              console.log "Group: #{e.key}"
            if !e.isGroup and !e.isGroupClose
              console.log "Property: #{e.key}", e.properties

          console.log "fin"
          #console.log "elements", util.inspect(@elements)
          resolve()
        , reject


  render: (line) =>
    return new Promise (resolve, reject) =>
      @parseLine(line)
        .then @setObjectLevel
        .then @setElement
        .then resolve, reject
        .catch (e) ->
          throw e

  processElements: () =>
    return new Promise (resolve, reject) =>
      for e in @elements
        if e.isGroup
          @setByPath



  setElement: (element) =>
    return new Promise (resolve, reject) =>
      #console.log "fireing setElement"
      @elements.push element
      return resolve()

  parseLine: (line) =>
    return new Promise (resolve, reject) =>
      #console.log "fireing parseLine"
      element = {
        name: line
        key: ""
        openTag: ""
        sectionData: ""
        properties: []
        hasProperties: false
        hasFunction:false
        isGroup: false
        isGroupClose: false
      }

      if element.name.indexOf(" = ") > -1
        #console.log 'element.name.indexOf(" = ") > -1'
        d = element.name.split(" = ")
        element.name = d[0]

        props = d[1].split(", ")
        if props.length == 1
          element.properties = props[0]
        else
          element.properties = props

        element.hasProperties = true

      if element.name.indexOf("(") > -1 and element.name.indexOf(")") > -1
        #console.log 'element.name.indexOf("(") > -1 and element.name.indexOf(")") > -1'
        c = element.name.split("(")
        element.name = c[0]
        element.sectionData = c[1].split(")")[0]
        element.hasFunction = true
      if @fileData.indexOf("End#{element.name}") > -1
        #console.log 'if @fileData.indexOf("End#{name}") > -1'
        element.isGroup = true
      else if element.name.indexOf("End") == 0
        #console.log 'element.name.indexOf("End") == 0'
        element.isGroupClose = true
        element.openTag = element.name.replace "End", ""
      #console.log "fireing parseLine - resolve"
      return resolve(element)

  setObject: (element) =>
    return new Promise (resolve, reject) =>
      index = @list.length - 1
      if element.isGroup
        @list.push new Element
        index = @list.length - 1



  setObjectLevel: (element) =>
    return new Promise (resolve, reject) =>
      ext = ""
      if @current.length > 0
        ext = "."

      #console.log "fireing setObjectLevel"
      if element.isGroup
        #console.log "element.isGroup"
        @current += "#{ext}#{element.name}"
        @groupLevel++
      #  console.log "isGroupOpen: @current", @current
        element.key = @current
      else if element.isGroupClose
        #console.log "element.isGroupClose"
        if @current.length == 0
          console.log "unable to close group", @current.length

        strToReplace = "#{ext}#{element.openTag}"
        index = @current.lastIndexOf(strToReplace)
        @current = @current.substring(0, index)
        @groupLevel--
        element.key = @current
      else
        element.key = "#{@current}#{ext}#{element.name}"

      element.groupLevel = @groupLevel
      #console.log "fireing setObjectLevel - resolve"
      return resolve(element)

module.exports = Solution


#      properties: [
#        "VisualStudioVersion",
#        "MinimumVisualStudioVersion"
#      ]



class Element
  constructor: ->



class Solution

  open: (@path) =>
    return new Promise (resolve, reject) =>
      @readFile(@path)
        .then @processFile, reject
        .then () =>
          console.log "open end"
  processFile: (data) =>
    return new Promise (resolve, reject) =>

      return resolve()

  readFile: (path) =>
    return new Promise (resolve, reject) =>
      fs.readFile @path, (err, data) =>
        if (err) throw err

module.exports = Solution





Object.byString = (o, s) ->
  s = s.replace(/\[(\w+)\]/g, ".$1") # convert indexes to properties
  s = s.replace(/^\./, "") # strip a leading dot
  a = s.split(".")
  while a.length
    n = a.shift()
    if n of o
      o = o[n]
    else
      return
  o




class Solution
  constructor: () ->
    @funcs = [
      "Project",
      "GlobalSection",
      "type"
    ]
    @current = "data"
    @subdir = []
  endsWith: (str, suffix) ->
    return str.indexOf(suffix, str.length - suffix.length) is not -1
  open: (@file) =>
    return new Promise (resolve, reject) =>
      rd = readline.createInterface {
        input: fs.createReadStream(@file)
        output: process.stdout
        terminal: false
      }
      rd.on "line", @onReadLine
      rd.on "close", () ->
        resolve()
  onReadLine: (line) =>
    l = line.replace(/\t/g, '').trim()
    if l.length > 0
      #console.log "Line", line
      if l.indexOf("End") == 0
        fe = l.replace("End", "")
        o = @current.replace(".#{fe}", "")
        console.log "oo", o, fe
        @current = @current.replace(".#{fe}", "")
        return
      for f in @funcs
        if l.indexOf(f) == 0
          @current = "#{@current}.#{f}"
          console.log "set", @current, l.indexOf(f), line
          return
    #console.log "current #{@current}"
module.exports = Solution


class Solution
  constructor: () ->
    @propTemplate = {}
    @data = {}

    @_level = []
    @_elements = []

    @current = ""

    @funcs = {
      "Project":
        "name": 0
        "path": 1
        "id": 2
        "templateid": -1
      "Global": {}
      "GlobalSection":
        "type": 0
    }

  open: (@file) =>
    return new Promise (resolve, reject) =>
      rd = readline.createInterface {
        input: fs.createReadStream(@file)
        output: process.stdout
        terminal: false
      }
      rd.on "line", @onReadLine
      rd.on "close", () ->
        resolve(@data)

  parseProperties: (line) =>
    if line.indexOf(" = ") > -1
      arr = line.split(" = ")[1].split(", ")
    else
      arr = []
    if @propTemplate?
      for n of @propTemplate
        if n is -1
          value = line.split("(")[1].split(")")[0]
          @setProperty "", value, ""
        else
          if arr[n]?
            @setProperty n, arr[n]
    else

  setProperty: (name, value, ext = ".") =>
    @data["#{@current}#{ext}#{name}"] = value

  onReadLine: (line) =>

    l = line.replace(/\t/g, '').trim()
    console.log "line: #{l}"
    if l.length > 0
      for f of @funcs
        console.log "f", f, l.indexOf(f)
        if l.indexOf("End") > -1
          arr = @current.split(".")
          ncurrent = arr[0]
          for i in [0...arr.length -1] by 1
            ncurrent += ".#{arr[i]}"
          @current = ncurrent
          console.log "current end", @current
          break
        if l.indexOf(f) > -1
          @current = "#{@current}.#{f}"
          console.log "current set", @current
          @propTemplate = @funcs[f]
          break

      console.log "parse"
      @parseProperties line

    #arr = line.split(' = ')
    #if arr.length > 1
    #  prop = arr[0]
    #  @[prop] = arr[1]






module.exports = Solution



readline = require "readline"

class Solution
  constructor: () ->
    @Projects = []
    @data = []
    @groupLevel = 0

  open: (@file) =>
    return new Promise (resolve, reject) =>
      @current = ""
      rd = readline.createInterface {
        input: fs.createReadStream(@file)
        output: process.stdout
        terminal: false
      }
      rd.on "line", @onReadLine
      rd.on "close", () ->
        resolve(@)

  onReadLine: (line) =>
    l = line.replace(/\t/g, '').trim()
    #this is a comment or header
    if l == "" or l.indexOf("#") == 0 or l.indexOf("Microsoft Visual Studio Solution File") == 0
      return

    @parseLine(l)
      .then @setObjectLevel
      .then @setData
      .done()

  setData: (data) =>
    return new Promise (resolve, reject) =>
      {name, attr} = data
      if attr.groupLevel == 0 and attr.hasProperties and !attr.isGroup and !attr.isGroupClose
        if attr.properties.length == 1
          @[name] = attr.properties[0]
        else
          @[name] = attr.properties
        console.log "is top level", name, @[name]
      if name is "Project"
        @Projects.push {
          typeId: @stripQuotes attr.funcData
          name: @stripQuotes attr.properties[0]
          path: @stripQuotes attr.properties[1]
          id: @stripQuotes attr.properties[2]
        }
      @data.push data
      return resolve(data)

  stripQuotes: (str) ->
    return str.replace(/"/g, '').trim()

  setObjectLevel: (data) =>
    return new Promise (resolve, reject) =>
      {name, attr} = data
      console.log "line name", name
      if attr.isGroup
        if @current.length > 0
          @current += "."
        @current += name
        @groupLevel++
        console.log "isGroupOpen: @current", @current
      if attr.isGroupClose
        if @current.length == 0
          throw "unable to close group"
        ext = ""
        if @current.indexOf "." > -1
          ext = "."
        strToReplace = "#{ext}#{attr.openTag}"
        index = @current.lastIndexOf(strToReplace)
        @current = @current.substring(0, index)
        @groupLevel--
      data.attr.groupLevel = @groupLevel
      return resolve(data)




  parseLine: (line) ->
    return new Promise (resolve, reject) ->
      name = line
      data = {
        hasProperties: false
        hasFunction:false
        isGroup: false
        isGroupClose: false
      }
      if name.indexOf(" = ") > -1
        d = name.split(" = ")
        name = d[0]
        data.properties = d[1].split(", ")
        data.hasProperties = true
      if name.indexOf("(") > -1 and name.indexOf(")") > -1
        d = name.split("(")
        name = d[0]
        data.funcData = d[1].split(")")[0]
        data.hasFunction = true

      switch name
        when "Project", "Global", "GlobalSection"
          data.isGroup = true
        when "EndProject", "EndGlobal", "EndGlobalSection"
          data.isGroupClose = true
          data.openTag = name.replace "End", ""
      return resolve({name: name, attr: data })
###
