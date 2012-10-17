require('http').maxSockets = 20;

var poised = require('../lib/index');
var main  = poised.http();
var www   = main.front('www');
www.listen(3000);

var wwwBack = www.back('www');
wwwBack.balance('weighted');

var server = wwwBack.server('server1', 'http://127.0.0.1:3001/');
server.keepAlive = true;
wwwBack.server('server2', 'http://127.0.0.1:3001/');

var http = require('http');
http.createServer(function (req, res) {
  res.end('hello');
}).listen(3001);


console.log(main.toString());
setInterval(function () { console.log(main.toString()) }, 5000);
