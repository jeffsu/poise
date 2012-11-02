var utils = require('./utils');
var http  = require('http');
var health = require('upbeat-health');

export class Server {
  include $m.EventEmitter;

  function initialize(reqOptions, options) {
    this.requestOptions = utils.parseHTTPOptions(reqOptions);
    this.requestOptionMethods = {};

    this.options = options || {};
    this.count   = 0;

    this.requestCount = 0;
    this.requestTime  = 0;

    this.interval = this.options.interval || 3000;
  }

  function inc() {
    this.count++;
  }

  function stop() {
    if (this.checker) this.checker.stop();
  }

  function start() {
    if (this.checker) this.checker.start();
  }

  // average response time
  function art() {
    if (this.requestCount == 0) return 0;
    return this.requestTime / this.requestCount;
  }

  function resetART() {
    this.requestCount = 0;
    this.requestTime  = 0;
  }

  function averageResponseTime() {
    return this.art();
  }

  function health(url, options, cb) {
    var opts = { url: url };
    opts.__proto__ = options;

    this.checker = health.checker(health.http(opts), opts);
    if (cb) this.checker.on('beat', #(err) { cb(err) });
    
    this.checker.on('beat',      #{ self.emit('beat', $1) });
    this.checker.on('healthy',   #{ self.emit('healthy') });
    this.checker.on('unhealthy', #{ self.emit('unhealthy') });
    this.checker.start();
  }

  function isHealthy() {
    if (!this.checker) return true;
    return this.checker.stat == 'healthy';
  }

  function handle(req, res, cb) {
    this.requestCount++;

    var startTime = (new Date).getTime();
    var proxy = this.request(req);

    req.on('error', #{ proxy.abort(); });

    proxy.on('response', #(proxyRes) {
      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      self.requestTime += (new Date).getTime() - startTime;

      proxyRes.on('data', #{ res.write($1) });
      proxyRes.on('end',  #{ res.end($1) });
    });

    proxy.on('error', #($1) { if (cb) cb($1) });

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

  function toString(indent) {
    indent = indent || "";
    var ret = indent + "SERVER: " + this.name + "\n";
    ret += indent + "  healthy:       " + (this.isHealthy() ? 'yes' : 'no') + "\n";
    ret += indent + "  avg resp time: " + (this.art() + 'ms') + "\n";
    ret += indent + "  request count: " + (this.count) + "\n";
    return ret;
  }
}

