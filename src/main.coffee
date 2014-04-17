{WSS} = require '../lib/wssjs/src/wss'
{List} = require '../src/list'

list = null
wss = null

onOpenCallback = (socket) ->
  onMessageCallback = (event) ->
    try
      packet = JSON.parse event.data
      throw new Error if packet.type != 'peering'
      list.add packet.originator, socket
    catch
      socket.close()

  socket.onmessage = onMessageCallback

exports.main = () ->
  # Allocating list
  list = new List
  # Putting websocket server in listening
  wss = new WSS
  wss.onopen = onOpenCallback
  wss.listen()
