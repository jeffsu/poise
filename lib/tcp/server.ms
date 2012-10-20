var net = require('net');
export class Server {
  function initialize(options) {
    this.options = this.parseOptions(options);
    this.conOpts = { host: this.options.host, port: this.options.port };
    this.connections = 0;
  }

  function parseOptions(options) {
    if (typeof options == 'string') {
      var splitted = options.split(':'); 
      return { host: splitted[0], port: parseInt(splitted[1]) };
    }
    return options;
  }

  function handle(socket) {
    this.connections++;
    var conn = net.connect(this.conOpts, #{ 
      conn.pipe(socket);
      socket.pipe(conn);
    }); 

    conn.on('end', #{ self.connections-- });
  }

  function isHealthy() {
    return true;
  }
}
