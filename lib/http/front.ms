var http = require('http');
var LB   = require('./lb');

export class Front {
  function initialize(options) {
    this.lbs  = [];
    this.options = options;
  }

  function back(name, filter) {
    var lb = new LB(filter); 
    lb.name = name;
    this.lbs.push(lb);
    return lb;
  }

  function listen(port, address) {
    this.port = port;
    http.createServer(#(req, res) {
      foreach (var lb in self.lbs)
        if (lb.match(req)) return lb.handle(req, res);

      res.send(404);
    }).listen(port, address);;
  }
}
