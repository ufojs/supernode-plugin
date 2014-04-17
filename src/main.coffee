{WSS} = require '../lib/wssjs/src/wss'
{List} = require '../src/list'

exports.main = () ->
  # Allocating list
  list = new List
  # Putting websocket server in listening
  wss = new WSS
  wss.listen()
