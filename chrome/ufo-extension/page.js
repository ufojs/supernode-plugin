console.log("page.js injected");
var port = chrome.runtime.connect({ name: 'ufo-page' });

var onMessageFromExtension = function(message) {
  var event = document.createEvent('HTMLEvents');
  event.initEvent('ufo-message-from-extension', true, true);
  event.data = message;
  window.dispatchEvent(event);
};

var onMessageFromPage = function(event) {
  console.log(event)
  port.postMessage(event.detail);
};

port.onMessage.addListener(onMessageFromExtension);
window.addEventListener('ufo-message-from-page', onMessageFromPage);
