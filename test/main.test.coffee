# Enabling BDD style
chai = require 'chai'
should = chai.should()
# Test lib
rewire = require 'rewire'
mainModule = null

class fakeWSS
  constructor: () ->
  listen: () ->
  onopen: (socket) ->

class fakeList
  constructor: () ->
  add: (id, node) ->

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

  it 'should register the onopen callback', (done) ->
    mainModule.__set__ 'onOpenCallback', () ->
      done()

    mainModule.main()
    wss = mainModule.__get__ 'wss'
    wss.onopen()

  it 'should set onmessage callback in onOpenCallback', (done) ->
    fakeSocket = {}
    callback = mainModule.__get__ 'onOpenCallback'
    callback fakeSocket
    fakeSocket.should.respondTo 'onmessage'
    done()

  it 'should add the socket to the list if a peering message is received', (done) ->
    message = 
      'type': 'peering',
      'originator': 'the id',
      'body': 'the body'
    message = JSON.stringify message
    event =
      'data': message
    fakeSocket = {}
    callback = mainModule.__get__ 'onOpenCallback'
    callback fakeSocket
    fakeList::add = (id, node) -> 
      fakeList::add = () ->
      id.should.be.equal 'the id'
      node.should.be.equal fakeSocket
      done()
    mainModule.__set__ 'list', new fakeList
    
    fakeSocket.onmessage event

  it 'should close if the received message is not a peering one', (done) ->
    message = 
      'type': 'not-peering',
      'originator': 'the id',
      'body': 'the body'
    message = JSON.stringify message
    event =
      'data': message
    fakeSocket = {}
    fakeSocket.close = () ->
      done()
    callback = mainModule.__get__ 'onOpenCallback'
    callback fakeSocket
    
    fakeSocket.onmessage event

  it 'should close if the received message is not an ufo packet', (done) ->
    message = 'not an ufo packet'
    message = JSON.stringify message
    event =
      'data': message
    fakeSocket = {}
    fakeSocket.close = () ->
      done()
    callback = mainModule.__get__ 'onOpenCallback'
    callback fakeSocket
    
    fakeSocket.onmessage event
