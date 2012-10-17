var Server = require('./server');
var lb     = require('./lb');

export class Back {
  function initialize(filter) {
    this.servers = {};
    this.count   = 0;
    this.useFilter(filter);

    this.lb = new lb.RoundRobin(this);
  }

  function balance(type, options) {
    if (this.lb) this.lb.clear();

    if (type == 'roundrobin') {
      this.lb = new lb.RoundRobin(this, options);
    }

    else if (type == 'weighted') {
      this.lb = new lb.Weighted(this, options);
    }

    this.lb.rebalance(this);

    return this.lb;
  }

  function match(req) {
    return this.filter ? this.filter(req) : true;
  }

  function useFilter(filter) {
    if (!filter) return;

    if (typeof filter == 'function') {
      this.filter = filter;
    } else {
      this.filter = #(req) {
        var headers = req.headers;
        for (var k in filter) {
          var val = headers[k];
          if (val && val.match(filter[k])) return true;
        }
        return false;
      };
    }
  }

  function server(name, reqOptions, options) {
    var server = new Server(reqOptions, options); 
    server.name = name;
    this.servers[name] = server;
    this.lb.rebalance(self);

    server.on('unhealthy', #{ self.lb.rebalance(); });
    server.on('healthy', #{ self.lb.rebalance(); });

    return server;
  }

  function resolve(inc) {
    return this.lb.resolve(this, inc);
  }

  function handle(req, res) {
    var server = this.resolve(true);
    return server ? server.handle(req, res) : false;
  }

  function toString(indent) {
    indent = indent || "";
    var ret = indent + "BACK: " + this.name + "\n";
    ret += this.lb.toString(indent + "  ");

    for (var name in this.servers) 
      ret += this.servers[name].toString(indent + "  ");
    return ret;
  }

}
