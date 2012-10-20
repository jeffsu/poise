var poised = require('../lib/index');
var tcp    = poised.tcp();
var google = tcp.front('google');
google.listen(4000);

var back = google.back('google');
back.server('main', 'www.google.com:80');
