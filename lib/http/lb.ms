var Server = require('./server');
export class LB {
  function initialize(filter) {
    this.servers = {};
    this.count   = 0;
    this.useFilter(filter);

    this.healthy = {};
    this.pool    = [];
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
    this.healthy[name] = server;
    this.servers[name] = server;
    this.buildPool();

    var isHealthy = true;
    server.on('unhealthy', #{ 
      console.log('unhealthy');
      isHealthy = false;
      delete self.healthy[name];
      self.buildPool();
    });

    server.on('healthy', #{
      if (isHealthy) return;

      isHealthy = true;
      self.healthy[name] = server;
      self.buildPool();
    });

    return server;
  }

  function getServer(inc) {
    var i = this.count % this.pool.length;
    if (inc) this.count++;
    return this.pool[i];
  }

  function handle(req, res) {
    var server = this.getServer(true);
    return server ? server.handle(req, res) : false;
  }

  function buildPool() {
    this.pool.length = 0;
    for (var k in this.healthy) this.pool.push(this.healthy[k]);
  }

}
