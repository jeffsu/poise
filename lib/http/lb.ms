
class Base {
  function initialize(options) {
    this.options = options || {};
    this.servers = {};
    this.healthy = [];
    this.init();
    this.rebalance(this);
  }

  function rebalance(back) {
    this.healthy.length = 0;
    for (var name in back.servers) {
      var server = back.servers[name];
      if (server.isHealthy()) this.healthy.push(name);
    }
    this.shuffle(back);
  }

  function clear() { }
  function shuffle() { }
}

public class RoundRobin extends Base {
  function init() {
    this.iterator = 0;
  }

  function resolve(back, inc) {
    this.iterator++;
    var serverName = this.healthy[this.iterator % this.healthy.length];
    var server     = back.healthy[serverName];
    if (inc && server) server.inc();
    return server;
  }
}

public class Resource extends Base {

}

public class Weighted extends RoundRobin {
  function init() {
    this.iterator = 0;
    this.subIterator = 0;
    this.weights = [];
    this.subMax  = 0;
  }

  function clear() {
    if (this.intervalId) clearInterval(this.intervalId);
    this.intervalId = null;
  }

  function shuffle(back) {
    var total = 0;
    var n = this.healthy.length;

    this.weights.length = 0;

    foreach (var name:i in this.healthy) {
      var server = back.servers[name];
      var art = server.art(); 
      total += art;
      this.weights.push(art);
    }

    var average = total / n;

    foreach (var n:i in this.weights) 
      this.weights[i] = Math.round(average/n);
  }

  function resolve(inc) {
    if (!this.current || (this.subIterator > this.subMax)) {
      this.subIterator = 1;
      var idx = this.iterator % this.healthyLength;
      this.current = this.healthy[idx];
      this.subMax  = this.weights[idx] || 0;
      this.iterator++;
    }

    if (inc  && this.current) this.current.inc();
    return this.current;
  }

}
