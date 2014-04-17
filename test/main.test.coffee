# Enabling BDD style
chai = require 'chai'
should = chai.should()
# Test lib
rewire = require 'rewire'
mainModule = null

class fakeWSS
  constructor: () ->
  listen: () ->

class fakeList
  constructor: () ->
  
describe 'The main method', ->
  
  beforeEach (done) ->
    mainModule = rewire '../src/main'
    mainModule.__set__ 'WSS', fakeWSS
    mainModule.__set__ 'List', fakeList
    done()

  it 'should put the websocket server in listening', (done) ->
    fakeWSS::listen = () ->
      fakeWSS::listen = () ->
      done()

    mainModule.main()

  it 'should allocate a node list', (done) ->
    class thisList extends fakeList
      constructor: () ->
        done()
    mainModule.__set__ 'List', thisList

    mainModule.main()
