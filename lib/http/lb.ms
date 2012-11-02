class Base {
  function initialize(back, options) {
    this.options   = options || {};
    this.servers   = back.servers;
    this.interval  = this.options.interval || 10000;
    this.healthy   = [];
    this.intervals = [];
    this.init();
    this.start();
    this.rebalance();
  }

  function rebalance() {
    this.healthy.length = 0;
    for (var name in this.servers) {
      var server = this.servers[name];
      if (server.isHealthy()) this.healthy.push(server);
    }
    this.shuffle();
  }

  function toString(indent) {
    return indent + "LOAD BALANCER: \n" + 
           indent + "  healthy: " + JSON.stringify(this.healthy.map(#{ => $1.name })) + "\n" +
           indent + "  options: " + JSON.stringify(this.options) + "\n";
  }

  function start() { 
    this.intervals.push(setInterval(#{ self.shuffle() }, this.interval));
  }

  function stop() {
    foreach (var id in this.intervals) clearInterval(id);
    this.intervals.length = 1;
  }


  function shuffle() { }
}

public class RoundRobin extends Base {
  function init() {
    this.iterator = 0;
  }

  function resolve(req, inc) {
    this.iterator++;
    var server = this.healthy[this.iterator % this.healthy.length];
    if (inc && server) server.inc();
    return server;
  }
}

public class Resource extends Base {
  private {
    var crypto = require('crypto');
  }

  function toInt(string) {
    return this.buff2hash(new Buffer(crypto.createHash('md5').update(string).digest()), 0);
  }

  function init(options) {
    this.getKey = this.options.key || #(req) { => req.url };
  }

  function resolve(req, inc) {
    var server = this.healthy[this.toInt(this.getKey(req)) % this.healthy.length];
    if (inc && server) server.inc();
    return server;
  }

  function buffToInt(buff, part) {
    var hash = 
      buff[part * 4 + 3] << 24 |
      buff[part * 4 + 2] << 16 |
      buff[part * 4 + 1] << 8 |
      buff[part * 4];

    return hash >>> 0;
  }

  function toInt(key) {
    var ret = this.buffToInt(new Buffer(crypto.createHash('md5').update(key).digest()), 0);
    return ret;
  }

}

public class Weighted extends RoundRobin {
  function init() {
    this.iterator    = 0;
    this.subIterator = 0;
    this.weights     = [];
    this.subMax      = 0;
  }

  function shuffle() {
    var total = 0;
    var n = this.healthy.length;

    this.weights.length = 0;

    foreach (var server:i in this.healthy) {
      var art = server.art(); 
      server.resetART();
      total += art;
      this.weights.push(art);
    }

    var avg = total / n;

    foreach (var n:i in this.weights)
      this.weights[i] = Math.round(avg/n);

    this.current = null;
    this.iterator = 0;
    this.subIterator = 0;
  }

  function toString(indent) {
    return this.$super(indent) + 
      indent + "  weights: " + JSON.stringify(this.weights) + "\n";
  }

  function resolve(req, inc) {
    if (!this.current) {
      this.current     = this.healthy[0];
      this.subIterator = 0;
      this.iterator++;
    } 
    
    else if (this.subIterator >= this.subMax) {
      var idx = this.iterator % this.healthy.length;
      this.current = this.healthy[idx];
      this.subMax  = this.weights[idx] || 0;
      this.subIterator = 0;
      this.iterator++;
    } 

    this.subIterator++;

    if (inc  && this.current) this.current.inc();
    return this.current;
  }
}
