var utils = require('./utils');
var http  = require('http');
var checker = require('./checker');

export class Server {
  include $m.EventEmitter;

  function initialize(reqOptions, options) {
    this.requestOptions = utils.parseHTTPOptions(reqOptions);
    this.requestOptionMethods = {};

    options = options || {};
    this.interval = options.interval || 3000;
  }

  function health(url, options, cb) {
    this.checker = new Checker(url, options || {}, cb);
  }

  function isHealthy() {
    if (!this.checker) return true;
    return this.checker.isHealthy;
  }

  function handle(req, res) {
    var proxy = this.request(req.method, req.url);

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

  function request(method, path, cb) {
    var options = this.requestOptionMethods[method];

    if (!options) {
      options = this.requestOptionMethods[method] = { method: method };
      for (var k in this.requestOptions) options[k] = options[k] || this.requestOptions[k];
    }

    options.path = path;
    var req = http.request(options);
    if (cb) {
      utils.handleResponse(req, cb);
      if (method == 'GET') req.end();
    }

    return req;
  }
}

