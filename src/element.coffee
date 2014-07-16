class Element

  createByPath: (path, value, checkIfExists = false) =>
    s = path.replace(/\[(\w+)\]/g, ".$1") # convert indexes to properties
    s = s.replace(/^\./, "") # strip a leading dot
    a = s.split(".")
    o = @
    while a.length
      n = a.shift()
      if !(n of o)
        o[n] = new Element
      if a.length > 0
        o = o[n]
      else
        o.setValue(n, value, checkIfExists)

  setValue: (name, value, checkIfExists = false) =>
    if checkIfExists and @[name]?
      return
    @[name] = value

module.exports = Element
