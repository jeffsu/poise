var http = require('http');

module.exports.http = function () {
  var server = http.createServer(function (req, res) { 
    server._count++;

    var data = "";
    req.on('data', function (chunk) { data += chunk.toString() });
    req.on('end', function () { 
      if (req.url == '/ok') {
        res.writeHead(200);
        res.end(data);
      } else {
        res.writeHead(500);
        res.end(data);
      }
    });
  });
  server._count = 0;
  return server;
};

var n = 0;
module.exports.step = function (cb) {
  setTimeout(cb, (++n * 100));
};
