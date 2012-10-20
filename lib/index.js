require('mochiscript');

var HTTP = require('./http');
var TCP  = require('./tcp');

module.exports.http = function () { return new HTTP() };
module.exports.tcp  = function () { return new TCP() };
