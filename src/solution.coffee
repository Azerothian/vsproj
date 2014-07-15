fs = require "fs"
Promise = require "bluebird"
readline = require "readline"

#      properties: [
#        "VisualStudioVersion",
#        "MinimumVisualStudioVersion"
#      ]



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





###
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
###
