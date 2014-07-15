fs = require "fs"
Promise = require "bluebird"
readline = require "readline"


class Solution
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

  onReadLine: (line) =>
    arr = line.split('=')
    if arr.length > 1
      prop = arr[0].trim()
      @[prop] = arr[1].trim()






module.exports = Solution
