var Server = require('./server');
export class Back {
  function initialize(options) {
    this.options = options;
    this.servers = {};
    this.pool    = [];
    this.count   = 0;
  }

  function handle(socket) {
    var server = this.resolve();
    server.handle(socket);
  }

  function resolve() {
    this.count++;
    var idx = this.count % this.pool.length;
    return this.pool[idx];
  }

  function server(name, options) {
    var server = this.servers[name] = new Server(options);
    server.name = name;
    this.rebalance();
    return server;
  }

  function rebalance() {
    this.pool.length = 0;
    for (var name in this.servers) {
      var server = this.servers[name];
      if (server.isHealthy()) this.pool.push(server);
    }
  }


}
