# Poised - HTTP Load Balancer in Node

# Why not HAProxy?
Poise at its core, aims to have most of the featureset that HAPRoxy has.  If you can get away with using HAProxy, you should!  If you need more... read on.

## More Flexibility
With poised, you can script load balancing logic as opposed to declaritively configure it.  You can also define when to add and evict servers.

## Node Integration
Poised can run standalone (see examples), but it can also be integrated into node. If you are running node in your stack, this means you can resolve your servers within your actual process instead of going through another proxy.

# Quick Start
Here is an example script load balancing 2 http servers:
```javascript
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

```javascript
var poised = require('poised');
var http = poised.http();
```

## front
This defines the front end of the proxy.  You should have one
front for each incomming port you are listening to.
```javascript
var www = http.front('www');
www.listen(80);
```

## back
This defines backends to route to.  Here, you can define which cluster
of servers you want to route to.

```javascript
var staticBack = www.back('static', { host: /^static/ });
var wwwBack    = www.back('www');
wwwBack.balance({ algorithm: 'weighted' });
staticBack.balance({ algorithm: 'resource' });
```

You can also define backups to backs:
```javascript
var backup = back.backup();
backup.server('server1', 'http://localhost:3001');
```

This creates a backup to the back.  Backup's abide by the same api as backs. 

## server
This introduces a server if to a back cluster.
```javascript
var server1 = wwwBack.server('server1', 'http://localhost:3000');
server1.health('http://localhost:3000/health');

var server2 = wwwBack.server('server1', 'http://localhost:3001');
var server3 = wwwBack.backup('server3', 'http://localhost:3001');
```

# Load balancing algorithms

Load balancing is set on the "back" object and defines how it chooses a server to hand the request to.  By default, load balancing is done using the roundrobin algorithm, but can use several different algorithms.

```
back.balance({ algorithm: 'weighted', interval: 10000 });
```

Standard options:

  1. algorithm: algorithm to use for balancing
  1. interval: the amount of time (in milliseconds) between each "shuffle" or rebalance.  For instance, the above code will recheck and rebalance the ratios on how to distrubute the payload every 10 seconds.


## roundrobin

This is the default way poise balances if none is defined.  The "interval" option is not applicable.

```javascript
back.balance({ algorithm: 'roundrobin' });
```

## weighted

Takes the average response times for each server and redistrubutes load accordingly.  For instance, if a server was twice as fast as another, it would get twice as much traffic.

```javascript
back.balance({ algorithm: 'weighted', interval: 10000 });
```

## resource

Makes requests "stick" to specific servers depending on which attribute to hash by.

```javascript
back.balance({ algorithm: 'resource', key: function (req) { return req.url } });
```

# Advanced Usage
```javascript
back.balance({
  algorithm: 'resource', 
  key: function (req) { return req.headers['servername'] }
});
```

```javascript
function shouldIntroduce(back, name, url) {
  var server = back.server(name, url);
  setTimeout(function () { 
    if (server.averageResponseTime() > 200) back.evict(name);
  }, 60000);
}
```

# Author
Jeff Su
