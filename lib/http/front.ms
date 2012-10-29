var http = require('http');
var Back   = require('./back');

export class Front {
  function initialize(options) {
    this.backs   = {};
    this.list    = [];
    this.options = options;
  }

  function back(name, filter) {
    var back  = new Back(filter); 
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

    this.server = http.createServer(#(req, res) {
      foreach (var back in self.list)
        if (back.match(req)) return back.handle(req, res);

      res.send(404);
    });

    this.server.listen(port, address);;
    return this.server;
  }

  function close() {
    this.stop();
  }

  function stop() {
    if (this.server) this.server.close();
    for (var k in this.backs) this.backs[k].stop();
  }
}
