require('http').maxSockets = 20;

// var poised = require('poised');
var poised = require('../lib/index');

// create initial http group
var main  = poised.http();

// listen on 3000 
var www   = main.front('www');
www.listen(3000);

// create a back for www
var wwwBack = www.back('www');

// use resource balancing 
wwwBack.balance({ algorithm: 'weighted', key: function (req) { return req.url } });

// add a server to wwwBack
var server = wwwBack.server('server1', 'http://127.0.0.1:3001/');
server.keepAlive = true;

// add second server
wwwBack.server('server2', 'http://127.0.0.1:3001/');

// create dummy server to proxy to
var http = require('http');
http.createServer(function (req, res) {
  res.end('hello');
}).listen(3001);


// debug information once every 5 seconds
console.log(main.toString());
setInterval(function () { console.log(main.toString()) }, 5000);
