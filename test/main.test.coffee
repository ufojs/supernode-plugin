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
    class CustomMockWebSocketServer extends MockWebSocketServer
      listen: () ->
        done()

    mainModule.__set__ 'WSS', CustomMockWebSocketServer
    mainModule.main()

  it 'should allocate a node list', (done) ->
    class CustomMockList extends MockList
      constructor: () ->
        done()
    mainModule.__set__ 'List', CustomMockList

    mainModule.main()

  it 'should register the onopen callback', (done) ->
    class CustomMockWebSocketServer extends MockWebSocketServer
      constructor: () ->
      listen: () ->
        this.should.respondTo 'onopen'
        done()

    thisMainModule = rewire '../src/main'
    thisMainModule.__set__ 'WSS', CustomMockWebSocketServer
    
    thisMainModule.main()
    

  it 'should set onmessage callback in onOpenCallback', (done) ->
    checkCallback = () ->
      WSSClass = mainModule.__get__ 'WSS'
      WSSClass.socketToSpawn.should.respondTo 'onmessage'
      done()

    mainModule.main()
    setTimeout checkCallback, 100


  it 'should set onclose callback in onOpenCallback', (done) ->
    checkCallback = () ->
      clearInterval spy
      WSSClass = mainModule.__get__ 'WSS'
      WSSClass.socketToSpawn.should.respondTo 'onclose'
      done()

    mainModule.main()
    spy = setInterval checkCallback, 100

  it 'should remove a node from the list when it goes away', (done) ->
    message = 
      'type': 'peering',
      'originator': 'the id',
      'body': 'the body'
    message = JSON.stringify message
    event =
      'data': message

    WSSClass = mainModule.__get__ 'WSS'
    socket = WSSClass.socketToSpawn

    class CustomMockList extends MockList
      remove: (id) -> 
        id.should.be.equal 'the id'
        done()
    mainModule.__set__ 'List', CustomMockList

    removeNodeCallback = () ->
      socket.onclose()

    addNodeCallback = () ->
      socket.onmessage event
      setTimeout removeNodeCallback, 50

    mainModule.main()
    addNodeCallback()
    setTimeout addNodeCallback, 100
    
  it 'should add the socket to the list if a peering message is received', (done) ->
    message = 
      'type': 'peering',
      'originator': 'the id',
      'body': 'the body'
    message = JSON.stringify message
    event =
      'data': message
        
    WSSClass = mainModule.__get__ 'WSS'
    socket = WSSClass.socketToSpawn
    
    MockList::add = (id, node) -> 
      MockList::add = () ->
      id.should.be.equal 'the id'
      node.should.be.equal socket
      done()
    mainModule.__set__ 'list', new MockList

    newNodeCallback = () ->
      socket.onmessage event

    mainModule.main()
    setTimeout newNodeCallback, 100

  it 'should close if the received message is not a peering one', (done) ->
    message = 
      'type': 'not-peering',
      'originator': 'the id',
      'body': 'the body'
    message = JSON.stringify message
    event =
      'data': message

    WSSClass = mainModule.__get__ 'WSS'
    socket = WSSClass.socketToSpawn
    socket.close = () ->
      done()

    newNodeCallback = () ->
      socket.onmessage event

    mainModule.main()
    setTimeout newNodeCallback, 100

  it 'should close if the received message is not an ufo packet', (done) ->
    message = 'not an ufo packet'
    message = JSON.stringify message
    event =
      'data': message

    WSSClass = mainModule.__get__ 'WSS'
    socket = WSSClass.socketToSpawn
    socket.close = () ->
      done()

    newNodeCallback = () ->
      socket.onmessage event

    mainModule.main()
    setTimeout newNodeCallback, 100


  it 'should respond to send call', (done) ->
    mainModule.should.respondTo 'send'
    done()

  it 'should send a packet to an id', (done) ->
    socket = {}
    socket.send = (message) ->
      message.should.be.equal '{"test":"packet"}'
      done()
    socket.close = () ->
    list = {}
    list['id'] = socket

    mainModule.__set__ 'list', list
    mainModule.send 'id', { 'test': 'packet' }

  it 'should close the socket once the message is sent', (done) ->
    socket = {}
    socket.send = (message) ->
    socket.close = () ->
      done()
    list = {}
    list['id'] = socket

    mainModule.__set__ 'list', list
    mainModule.send 'id', { 'test': 'packet' }

  it 'should manage the id absence', (done) ->
    list = {}
    sendMethod = () ->
      mainModule.send 'id', { 'test': 'packet' }

    mainModule.__set__ 'list', list
    sendMethod.should.not.throw()
    done()

