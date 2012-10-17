
class Base {
  function initialize(back, options) {
    this.options = options || {};
    this.servers = back.servers;
    this.healthy = [];
    this.init();
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

  function clear() {
    if (this.intervalId) clearInterval(this.intervalId);
    this.intervalId = null;
  }


  function shuffle() { }
}

public class RoundRobin extends Base {
  function init() {
    this.iterator = 0;
  }

  function resolve(inc) {
    this.iterator++;
    var server = this.healthy[this.iterator % this.healthy.length];
    if (inc && server) server.inc();
    return server;
  }
}

public class Resource extends Base {

}

public class Weighted extends RoundRobin {
  function init() {
    this.iterator    = 0;
    this.subIterator = 0;
    this.weights     = [];
    this.subMax      = 0;
    this.intervalId = setInterval(#{ self.shuffle() }, 10000);
  }

  function shuffle() {
    var total = 0;
    var n = this.healthy.length;

    this.weights.length = 0;

    foreach (var server:i in this.healthy) {
      var art = server.art(); 
      total += art;
      this.weights.push(art);
    }

    var average = total / n;

    foreach (var n:i in this.weights) 
      this.weights[i] = Math.round(average/n);
  }

  function toString(indent) {
    return this.$super(indent) + 
      indent + "  weights: " + JSON.stringify(this.weights) + "\n";
  }

  function resolve(inc) {
    if (!this.current || (this.subIterator > this.subMax)) {
      this.subIterator = 1;
      var idx = this.iterator % this.healthy.length;

      this.current = this.healthy[idx];
      this.subMax  = this.weights[idx] || 0;
      this.iterator++;
    }

    if (inc  && this.current) this.current.inc();
    return this.current;
  }

}
