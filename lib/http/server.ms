var utils = require('./utils');
var http  = require('http');
var checker = require('./checker');

export class Server {
  include $m.EventEmitter;

  function initialize(reqOptions, options) {
    this.requestOptions = utils.parseHTTPOptions(reqOptions);
    this.requestOptionMethods = {};

    this.options = options || {};
    this.interval = this.options.interval || 3000;
  }

  function health(url, options, cb) {
    this.checker = new Checker(url, options || {}, cb);
    this.checker.start();

    this.checker.on('healthy', #{ self.emit('healthy') });
    this.checker.on('unhealthy', #{ self.emit('unhealthy') });
  }

  function isHealthy() {
    if (!this.checker) return true;
    return this.checker.isHealthy;
  }

  function handle(req, res) {
    var proxy = this.request(req);

    req.on('error', #{ proxy.abort(); });

    proxy.on('response', #(proxyRes) {
      res.writeHead(proxyRes.statusCode, proxyRes.headers);

      proxyRes.on('data', #{ res.write($1) });
      proxyRes.on('end',  #{ res.end($1) });
    });

    if (req.method == 'GET') {
      proxy.end();
    } else {
      req.on('data', #{ proxy.write($1) });
      req.on('end',  #{ proxy.end() });
    }
  }

  function request(req, cb) {
    var method  = req.method;
    var options = this.requestOptionMethods[method];

    if (!options) {
      options = this.requestOptionMethods[method] = { method: method };
      for (var k in this.requestOptions) options[k] = options[k] || this.requestOptions[k];
    }

    options.path    = req.url;
    options.headers = req.headers;
    if (this.options.keepAlive) options.headers.connection = "keep-alive";

    var req = http.request(options);
    if (cb) {
      utils.handleResponse(req, cb);
      if (method == 'GET') req.end();
    }

    return req;
  }
}

