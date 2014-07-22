fs = require "fs"
util = require "util"
xml2js = require "xml2js"
parser = new xml2js.Parser()
map = require "coffeemapper"

debug = require("debug")("vsproj:project")

Promise = require "bluebird"

elementMap = {
  path: (src, res, rej) ->
    debug "elementMap.name"
    if src["$"]?
      if src["$"].Include?
        res(src["$"].Include)
    rej()
  dependent: (src, res, rej) ->
    debug "elementMap.dependent"
    if src.DependentUpon?
      res(src.DependentUpon[0])
    rej()
  subtype: (src, res, rej) ->
    debug "elementMap.subtype"
    if src.SubType?
      res(src.SubType[0])
    rej()

}



projectMap = {
  "References": (src, resolve, reject) ->
    debug "projectMap.References",
    refMap = {
      name: (src, resolve, reject) ->
        debug "projectMap.refMap.name"
        resolve(src["$"].Include)
      path: (src, resolve, reject) ->
        debug "projectMap.refMap.path"
        if src.HintPath?
          value = src.HintPath[0]
          resolve(value)
        reject()
      private: (src, resolve, reject) ->
        debug "projectMap.refMap.private"
        if src.Private?
          resolve(src.Private[0] is 'True')
        reject()
    }

    refs = []
    for e in src.Project.ItemGroup
      if e.Reference?
        refs = refs.concat e.Reference

    debug "projectMap.References.startmap"
    map(refs, refMap).then resolve, reject
  "Content": (src, resolve, reject) ->
    debug "projectMap.Content"
    refs = []
    for e in src.Project.ItemGroup
      if e.Content?
        refs = refs.concat e.Content
    map(refs, elementMap).then resolve, reject
  "Compile": (src, resolve, reject) ->
    debug "projectMap.Compile"
    refs = []
    for e in src.Project.ItemGroup
      if e.Compile?
        refs = refs.concat e.Compile
    map(refs, elementMap).then resolve, reject
  "Folder": (src, resolve, reject) ->
    debug "projectMap.Folder"
    refs = []
    for e in src.Project.ItemGroup
      if e.Folder?
        refs = refs.concat e.Folder
    map(refs, elementMap).then resolve, reject

}




class Project

  open: (@file) =>
    return new Promise (resolve, reject) =>
      fs.readFile @file, (err, data) =>
        if err?
          debug err, @file
          return reject(err)
        parser.parseString data, (err, @xml) =>
          if err?
            debug err, @file
            return reject(err)
          map(@xml, projectMap, undefined, @).then () =>
            debug "Project", @
            resolve(@)
          , reject


module.exports = Project


###
var fs = require('fs'),
    xml2js = require('xml2js');

var parser = new xml2js.Parser();
fs.readFile(__dirname + '/foo.xml', function(err, data) {
    parser.parseString(data, function (err, result) {
        console.dir(result);
        console.log('Done');
    });
});
###
