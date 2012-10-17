require('mochiscript');
var HTTP = require('./http');
module.exports.http = function () { return new HTTP() };
