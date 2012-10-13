var utils = require('./utils');
var http  = require('http');

export class Checker {
  include $m.EventEmitter;

  private {
    var DEFAULT_INTERVAL = 3;
  }

  function initialize(url, options, cb) {
    this.options  = utils.parseHTTPOptions(url);
    this.interval = options.interval || DEFAULT_INTERVAL;
    this.stat     = 'stopped';
    this.isHealthy = false;

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
      var error = self.getError(err, body, res);
      self.isHealthy = !error;
      if (error) self.lastError = error;
    });
    req.end();
  }

  function stop() {
    this.stat = 'stopped';
  }

  function start() {
    this.stat = 'running';

    function beat(err, pass) {
      if (!err) self.isHealthy = pass;
      if (self.stat != 'running') return;
      setTimeout(#{ self.checkHealth(beat) }, self.interval);
    }

    this.checkHealth(beat);
  }


}
