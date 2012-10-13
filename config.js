var ha = require('./lib/index');
var www = ha.http.front('www');
www.listen(3000);

var staticBack = www.back('static', { host: /^static/ });
staticBack.server("server1", "http://www.google.com");

var staticBack = www.back('www', function (req) { return true });
staticBack.server("server1", "http://www.google.com");
