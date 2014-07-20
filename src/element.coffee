util = require "util"
debug = require("debug")("vsproj:element")
Promise = require "bluebird-chains"
class Element
  constructor: (data) ->
    @elements = []

    if data?
      for o of data
        @[o] = data[o]

  getElement: (name) =>
    for e in @elements
      if e.name is name
        return e

  getElementsByName: (name) =>
    return new Promise (resolve, reject) =>
      debug "getElementsByName #{name}"
      r = []
      for e in @elements
        if e.name is name
          r.push e
      debug "getElementsByName #{name} total: #{r.length}"
      resolve(r)


  push: () =>
    @elements.push.apply @elements, arguments




module.exports = Element
