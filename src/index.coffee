
Promise = require "bluebird"
vsSolution = require "./solution"

class VsProj

  @openSolution: (file) ->
    return new Promise (resolve, reject) ->
      sol = new vsSolution()
      sol.open(file).then (elements) ->
        resolve(elements)




module.exports = VsProj
