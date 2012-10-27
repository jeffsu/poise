var http = require('http');

module.exports.http = function () {
  var server = http.createServer(function (req, res) { 
    server._count++;
    if (req.url == '/ok') {
      res.writeHead(200);
      res.end('ok');
    } else {
      res.writeHead(500);
      res.end('notok');
    }
  });
  server._count = 0;
  return server;
};

var n = 0;
module.exports.step = function (cb) {
  setTimeout(cb, (++n * 100));
};
