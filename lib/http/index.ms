var Front = require('./front');

export class HTTP {
  function initialize() {
    this.fronts = {};
  }

  function front(name, options) {
    var front = this.fronts[name] = new Front(options);
    front.name = name;
    return front;
  }

  function toString(indent) {
    indent = indent || "";
    var ret = indent + "HTTP\n";
    for (var k in this.fronts) {
      ret += this.fronts[k].toString(indent + "  ");
    }
    return ret;
  }
}

