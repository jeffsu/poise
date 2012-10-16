var http = require('http');
var LB   = require('./lb');
var domain = require('domain');

export class Front {
  function initialize(options) {
    this.lbs  = [];
    this.options = options;
  }

  function lb(name, filter) {
    var lb = new LB(filter); 
    lb.name = name;
    this.lbs.push(lb);
    return lb;
  }

  function listen(port, address) {
    this.port = port;

    var serverDomain = domain.create();

    serverDomain.run(#{
      http.createServer(#(req, res) {
        var reqd = domain.create();
        reqd.add(req);
        reqd.add(res);
        reqd.on('error', #{ console.log($1); res.end('error'); });

        foreach (var lb in self.lbs)
          if (lb.match(req)) return lb.handle(req, res);

        res.send(404);
      }).listen(port, address);;
    });
  }
}
