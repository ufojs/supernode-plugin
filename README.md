ufojs supernode plugin
===============

Chrome application for ufojs supernodes

[![GithubTag](http://img.shields.io/github/tag/ufojs/supernode-plugin.svg)](https://github.com/ufojs/supernode-plugin)
[![Node Dependencies](https://david-dm.org/ufojs/network-layer/dev-status.svg)](https://david-dm.org/ufojs/supernode-plugin#info=devDependencies)
[![Build Status](https://travis-ci.org/ufojs/supernode-plugin.svg?branch=master)](https://travis-ci.org/ufojs/supernode-plugin)
[![Stories in Ready](https://badge.waffle.io/ufojs/supernode-plugin.png?label=ready&title=Ready)](https://waffle.io/ufojs/supernode-plugin)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://badges.mit-license.org)

This chrome application enables a common ufo peer with the supernode functionalities.

Once obtained the source code with the usual ``git clone https://github.com/ufojs/supernode-plugin``, use ``npm install`` to install all the dependancies and build the application.

Then you can install it by using *Load unpacked extension...* button from the Chrome settings page. As soon as possible I will implement the automatic bundler for the application.

All the tests can be run using ``npm test``. 

Look at ``package.json`` to learn all the project shortcuts.

### How to use

You can interact with the plugin using the common Chrome APP interface. You have to:
```
\\ connect to the extension
var port = chrome.runtime.connect('cpbbgbmhgobhoakmbbjojjjdngnfbdbo');
\\ set the message callback
var onPortMessage = function(message) {
  \\ it is fired when an external node sends a new message
  ...
  \\ send a reply message to the external node using the Chrome message API
  port.postMessage({ 'body': 'a message', 'destination': 'the destination' });
};
port.onMessage.addListener(onPortMessage);
```
