var utils = require('./utils');
var http  = require('http');

export class Checker {
  include $m.EventEmitter;

  private {
    var DEFAULT_INTERVAL = 3000;
  }

  function initialize(url, options, cb) {
    this.options  = utils.parseHTTPOptions(url);
    this.interval = options.interval || DEFAULT_INTERVAL;
    this.stat     = 'stopped';
    this.isHealthy = null;

    if (this.options) {
      cb = cb || #(err, body, res) {
        if (err) return err;
        return res.statusCode < 400 ? false : res.statusCode;
      };

      this.getError = cb;
    }

    this.start();
  }

  function checkHealth(cb) {
    var req = http.request(this.options);
    utils.handleResponse(req, #(err, body, res) { 
      var oldHealth = self.isHealthy;

      var error = self.getError(err, body, res);
      self.isHealthy = !error;
      if (error) self.lastError = error;

      if (oldHealth !== self.isHealthy) {
        if (self.isHealthy) self.emit('healthy');
        else self.emit('unhealthy', error);
      }
    });
    req.end();
  }

  function stop() {
    this.stat = 'stopped';
  }

  function start() {
    this.stat = 'running';

    function run() {
      self.checkHealth(beat);
    }

    function beat(err, pass) {
      if (!err) self.isHealthy = pass;
      if (self.stat != 'running') return;
      setTimeout(run, self.interval);
    }

    run();
  }


}
