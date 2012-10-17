# Poised - HTTP Load Balancer in Node

# Why not HAProxy?
Well, if you can get away with HAProxy, you should!  If you need more... read on.

## More Flexibility
With poised, you can script load balancing logic as opposed to declaritively configure it.  
You can also define when to add and evict servers.

## Node Integration
Poised can run standalone (see examples), but it can also be integrated into node. If you are running 
node in your stack, why not just resolve your servers within your actual process instead of going through 
another proxy.

# Quick Start
Here is an example script load balancing 2 http servers:
```
var poised = require('poised');
var http   = poised.http();

var front = http.front('main-www');
front.listen(80);

var back = front.back('main-www');
back.server('server1', 'http://127.0.0.1:3000/');
back.server('server2', 'http://127.0.0.1:3001/');
```

Just save this in a file and run "node <file>".

# Documentation
## http
This defines the protocol (only http for now) scope.

```
var poised = require('poised');
var http = poised.http();
```

## front
This defines the front end of the proxy.  You should have one
front for each incomming port you are listening to.
```
var www = http.front('www');
www.listen(80);
```

## back
This defines backends to route to.  Here, you can define which cluster
of servers you want to route to.
```
var staticBack = www.back('static', { host: /^static/ });
var wwwBack    = www.back('www');
wwwBack.balance({ algorithm: 'weighted' });
staticBack.balance({ algorithm: 'resource' });
```

## server
This introduces a server if to a back cluster.
```
var server1 = wwwBack.server('server1', 'http://localhost:3000');
server1.health('http://localhost:3000/health');

var server2 = wwwBack.server('server1', 'http://localhost:3001');
var server3 = wwwBack.backup('server3', 'http://localhost:3001');
```

# Load balancing algorithms
## roundrobin
## weighted
## resource

# Advanced Usage
```
back.balance({
  algorithm: 'resource', 
  key: function (req) { return req.headers['servername'] }
});
```

```
function shouldIntroduce(back, name, url) {
  var server = back.server(name, url);
  setTimeout(function () { 
    if (server.averageResponseTime() > 200) back.evict(name);
  }, 60000);
}
```

# Author
Jeff Su
