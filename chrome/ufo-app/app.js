chrome.app.runtime.onLaunched.addListener(function() {
  var confs = {
    bounds: { width: 250, height: 300 }
  };

  var onPageConnected = function(port) {
    var onServerMessage = function(message) {
      port.postMessage(message);
    };

    var onPageMessage = function(message) {
      ufo.send(message.destination, message.body);
    };

    var onListChanged = function(list) {
      console.log(list);
    };

    port.onMessage.addListener(onPageMessage);
    ufo.main(onServerMessage, onListChanged);
  };

  
  chrome.app.window.create('app.html', confs);
  chrome.runtime.onConnectExternal.addListener(onPageConnected);
});
