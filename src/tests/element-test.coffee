Element = require "../element"
expect = require('chai').expect
util = require "util"

describe 'Element', () ->
  it 'Open', () ->
    ele = new Element
    ele.createByPath "test.12.asadxz", []
    expect(ele.test["12"].asadxz?).to.equal(true)
