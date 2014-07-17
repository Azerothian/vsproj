Element = require "../element"
expect = require('chai').expect
util = require "util"

describe 'Element', () ->
  it 'Open', () ->
    ele = new Element
    ele.push []
    expect(ele.elements.length).to.equal(1)
