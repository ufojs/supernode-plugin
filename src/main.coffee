{WSS} = require '../lib/wssjs/src/wss'
{List} = require '../src/list'

list = null
wss = null

exports.send = (id, packet) ->
  node = list[id]
  return if not node?
  packet = JSON.stringify packet
  node.send packet
  node.close()

exports.main = (onListChanged) ->
  onOpenCallback = (socket) ->
    originator = null

    onMessageCallback = (event) ->
      try
        packet = JSON.parse event.data
        throw new Error if packet.type != 'peering'
        list.add packet.originator, socket
        originator = packet.originator
      catch error
        socket.close()
    onCloseCallback = () ->
      list.remove originator if originator?

    socket.onmessage = onMessageCallback
    socket.onclose = onCloseCallback

  # Allocating list
  list = new List
  list.onnodeadded = onListChanged
  list.onnoderemoved = onListChanged
  # Putting websocket server in listening
  wss = new WSS
  wss.onopen = onOpenCallback
  wss.listen()
