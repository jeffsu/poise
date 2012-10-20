var Back = require('./back');
var net  = require('net');

export class Front {
  function initialize(options) {
    this.options = options
    this.backs = {};
    this.pool  = [];
    this.server = net.createServer(#{ self.handle($1) });
  }

  function back(name, options) {
    var back = this.backs[name] = new Back(options); 
    this.pool.push(back);
    back.name = name;
    return back;
  }

  function listen() {
    this.server.listen.apply(this.server, arguments);
  }

  function handle(socket) {
    this.pool[0].handle(socket);
  }
}
