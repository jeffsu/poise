# Poised - HTTP Load Balancer in Node

Load balancing with health checks.

# Why not HAProxy?

## More Flexibility

If you don't need flexibility, then HAProxy is the better tool to use.  With poised, you can script
load balancing logic as opposed to declaritively configure it.

## Node Integration

Poised can run standalone (see examples), but it can also be integrated into node. If you are running 
node in your stack, why not just resolve your servers within your actual process instead of going through 
another proxy.

