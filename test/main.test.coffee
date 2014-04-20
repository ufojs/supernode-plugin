# Enabling BDD style
chai = require 'chai'
should = chai.should()
# Test lib
rewire = require 'rewire'
mainModule = null
# Mock lib
{MockWebSocketServer} = require '../lib/ufo-mocks/websocket-server.mock'
{MockList} = require '../lib/ufo-mocks/list.mock'

describe 'The main method', ->
  
  beforeEach (done) ->
    mainModule = rewire '../src/main'
    mainModule.__set__ 'WSS', MockWebSocketServer
    mainModule.__set__ 'List', MockList
    done()

  it 'should accept onListChanged callback', (done) ->
    callback = (theList) ->
    mainModule.main callback
    currentList = mainModule.__get__ 'list'
    currentList.onnodeadded.should.be.equal callback
    currentList.onnoderemoved.should.be.equal callback
    done()

  it 'should put the websocket server in listening', (done) ->
    MockWebSocketServer::listen = () ->
      MockWebSocketServer::listen = () ->
      done()

    mainModule.main()

  it 'should allocate a node list', (done) ->
    class thisList extends MockList
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

  it 'should set onclose callback in onOpenCallback', (done) ->
    fakeSocket = {}
    callback = mainModule.__get__ 'onOpenCallback'
    callback fakeSocket
    fakeSocket.should.respondTo 'onclose'
    done()

  it 'should remove a node from the list when it goes away', (done) ->
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
    MockList::remove = (id) -> 
      MockList::remove = (id) -> 
      id.should.be.equal 'the id'
      done()
    mainModule.__set__ 'list', new MockList
    
    fakeSocket.onmessage event
    fakeSocket.onclose()

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
    MockList::add = (id, node) -> 
      MockList::add = () ->
      id.should.be.equal 'the id'
      node.should.be.equal fakeSocket
      done()
    mainModule.__set__ 'list', new MockList
    
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
