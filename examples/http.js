var poise = require('../lib/index');
var www   = poise.http.front('www');
www.listen(3000);

var staticLB = www.lb('www', { host: /^localhost/ });
var server1 = staticLB.server("server1", "http://www.factual.com");
server1.health("http://www.factual.com");
server1.options.keepAlive = true;

var server2 = staticLB.server("server2", "http://www.factual.com");
server2.health("http://www.factual.blah");
server2.options.keepAlive = true;

var server3 = staticBack.server("server3", "http://www.factual.com");

server2.on('unhealthy', function () { console.log('server2 unhealthy') });
server1.on('healthy',   function () { console.log('server1 healthy') });