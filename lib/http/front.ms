var http = require('http');
var Back   = require('./back');
var domain = require('domain');

export class Front {
  function initialize(options) {
    this.backs  = {};
    this.list   = [];
    this.options = options;
  }

  function back(name, filter) {
    var back = new Back(filter); 
    back.name = name;
    this.list.push(back);
    return this.backs[name] = back;
  }

  function toString(indent) {
    indent = indent || "";
    var ret = indent + "FRONT: " + this.name + "\n";

    for (var name in this.backs) {
      var back = this.backs[name];
      ret += back.toString(indent + "  ");
    }
    return ret;
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

        foreach (var back in self.list)
          if (back.match(req)) return back.handle(req, res);

        res.send(404);
      }).listen(port, address);;
    });
  }
}
