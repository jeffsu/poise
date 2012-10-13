var Front = require('./front');
var LB    = require('./lb');

module.exports.front = #(name, options) {
  var front = new Front(options);
  front.name = name;
  return front;
};
