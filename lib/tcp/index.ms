var Front = require('./front');
export class TCP {
  function initialize() {
    this.fronts = {};
  }

  function front(name, options) {
    return this.fronts[name] = new Front(options);
  }
}
