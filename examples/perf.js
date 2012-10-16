require('http').maxSockets = 20;

var poise = require('../lib/index');
var www   = poise.http.front('www');
www.listen(3000);

var wwwLB = www.lb('www');
var server = wwwLB.server('server1', 'http://127.0.0.1:3001/');
server.keepAlive = true;

var http = require('http');
http.createServer(function (req, res) {
  res.end('hello');
}).listen(3001);

