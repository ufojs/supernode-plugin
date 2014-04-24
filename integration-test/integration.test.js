describe('A test', function() {
  var port = null;

  before(function(done) {
    port = chrome.runtime.connect('cpbbgbmhgobhoakmbbjojjjdngnfbdbo');
    setTimeout(done, 1000);
  });

  it('should accept a websocket connection', function(done) {
    var ws = new WebSocket('ws://localhost:9000');
    ws.onopen = function(event) {
      done();
    };
  });
  it('should close the connection if an invalid string is sent', function(done) {
    var ws = new WebSocket('ws://localhost:9000');
    ws.onopen = function(event) {
      ws.send('invalid string');
    };
    ws.onclose = function() {
      done();
    };
  });
  it('should accept a peering request', function(done) {
    var ws = new WebSocket('ws://localhost:9000');
    ws.onopen = function(event) {
      var onPortMessage = function(message) {
        port.onMessage.removeListener(onPortMessage);
        done();
      };
      port.onMessage.addListener(onPortMessage);
      ws.send(JSON.stringify({'type': 'peering', 'originator': 'op'}));
    };
  });
  it('should send a message to a connected websocket', function(done) {
    var ws = new WebSocket('ws://localhost:9000');
    ws.onopen = function(event) {
      ws.onmessage = function(event) { 
        console.log('received reply');
        done(); 
      };
      var sendOverPort = function() {
        port.postMessage({ 'body': {'type': 'peeringReply', 'originator': 'me'}, 'destination': 'op' });
        console.log('message sent over port');
      };
      ws.send(JSON.stringify({'type': 'peering', 'originator': 'op'}));
      setTimeout(sendOverPort, 1000);
    };
  });
});
