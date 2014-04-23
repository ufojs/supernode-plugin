var onPageConnect = function(port) {
  if(port.name != 'ufo-page') return;
  console.log('page connected');
  
  var onMessageFromPage = function(message) {
    console.log(message);
  };

  port.onMessage.addListener(onMessageFromPage);
};

//var onAppMessage = function(request, sender, sendResponse) {
  //console.log('app message');
  //console.log(request);
  //console.log(sender);
//};

//chrome.runtime.onMessageExternal.addListener(onAppMessage);
chrome.runtime.onConnect.addListener(onPageConnect);
