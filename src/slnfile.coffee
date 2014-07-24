fs = require "fs"
Promise = require "bluebird"
Chains = require "bluebird-chains"
util = require "util"
debug = require("debug")("vsproj:slnfile")
Element = require "./element"

newline = "\n"

class SlnFile extends Element
  open: (@file) =>
    return new Promise (resolve, reject) =>
      @list = [@]
      fs.readFile @file, "utf8", (err, @fileData) =>
        if err?
          throw err
        lines = @fileData.split newline
        a = new Chains
        for line in lines
          l = line.replace(/\t/g, '').trim()
          if l != "" and l.indexOf("#") != 0 and l.indexOf("Microsoft Visual Studio Solution File") != 0
            a.push @render, [l]
        debug "parseing lines"
        return a.last().then () =>
          resolve(@list[0])
        , reject

  save: (path = @file) =>
    return new Promise (resolve, reject) =>
      lines = "#{newline}"
      lines += "Microsoft Visual Studio Solution File, Format Version 12.00#{newline}"
      lines += "# Visual Studio 2013#{newline}"
      lines += @assembleLine @

      fs.writeFile path, lines, (err) ->
        if err?
          throw err
        resolve(lines)

  assembleLine: (e, indent = -1) ->
    line = @createTabs indent

    if e.name?
      line += "#{e.name}"

    if e.hasArgs
      line += "(#{e.args})"

    if e.hasProperties
      line += " = "
      for p in e.properties
        line += "#{p}, "
      line = line.substring 0, line.lastIndexOf(',')

    line += newline

    if e.elements?
      for ele in e.elements
        i = indent + 1
        line += @assembleLine(ele, i)
    if e.isGroup
      line += @createTabs indent
      line += "End#{e.name}#{newline}"
    return line

  createTabs: (indent) ->
    line = ""
    if indent > 0
      ii = 0
      while ii < indent
        line += "\t"
        ii++
    return line


  render: (line) =>
    return new Promise (resolve, reject) =>
      @parseLine(line)
        .then @processElement
        .then resolve, reject
        .catch (e) ->
          throw e


  processElement: (e) =>
    return new Promise (resolve, reject) =>
      if e.isGroupClose and @list.length > 1
        l = @list.pop()
        @list[@list.length - 1].push l
      else if e.isGroup
        @list.push e
      else if !e.isGroupClose and !e.isGroup
        @list[@list.length - 1].push e
      return resolve()



  parseLine: (line) =>
    return new Promise (resolve, reject) =>
      e = new Element()
      name = line
      if name.indexOf(" = ") > -1
        d = name.split(" = ")
        name = d[0]
        props = d[1].split(", ")

        e.properties = []
        for p in props
          e.properties.push @cleanString(p)
        e.hasProperties = true

      if name.indexOf("(") > -1 and name.indexOf(")") > -1
        c = name.split("(")
        name = c[0]
        args = c[1].split(")")[0] #assuming only one arg is allowed
        if args?
          e.args = @cleanString(args)
        e.hasArgs = true
      if @fileData.indexOf("End#{name}") > -1
        e.isGroup = true
      else if name.indexOf("End") == 0
        e.isGroupClose = true
      e.name = @cleanString(name)
      return resolve(e)

  quoteString: (str) ->
    return "\"#{str}\""

  cleanString: (str) ->
    return str
    #return str.replace(/"/g, '').trim()

module.exports = SlnFile
