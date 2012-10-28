var http = require('http');
var all = [];

module.exports.reset = function () {
  n = 0;
};

module.exports.http = function (timeout) {
  timeout = timeout || 0;
  var server = http.createServer(function (req, res) { 
    server.counts.req++;

    var data = "";
    req.on('data', function (chunk) { data += chunk.toString() });
    req.on('end', function () { 
      setTimeout(function () {
        if (req.url == '/ok') {
          server.counts.ok++;
          res.writeHead(200);
          res.end(data);
        } 

        else if (req.url == '/health') {
          server.counts.health++;
          res.writeHead(200);
          res.end("");
        }
        
        else {
          server.counts.errors++;
          res.writeHead(500);
          res.end(data);
        }
      }, timeout);
    });
  });
  server.counts = { ok: 0, health: 0, req: 0, errors: 0 };
  all.push(server);
  return server;
};

module.exports.close = function (cb) {
  for (var i=0; i<all.length; i++) all[i].close();
};

var n = 0;
module.exports.step = function (cb) {
  setTimeout(cb, (++n * 300));
};
