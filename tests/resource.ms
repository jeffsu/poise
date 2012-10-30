var setup  = require('./setup');
var poised = require('../');
var request = require('request');

module.exports['test http resource'] = function (test) {
  setup.reset();

  var server1 = setup.http(5); 
  server1.listen(3001);

  var server2 = setup.http(10); 
  server2.listen(3002);

  var front = poised.http().front('main');
  front.listen(3003);

  var back = front.back('main');
  back.balance({ algorithm: 'resource' }) 

  back.server('3001', 'http://localhost:3001').health('http://localhost:3001/health', { interval: 10 });
  back.server('3002', 'http://localhost:3002').health('http://localhost:3002/health', { interval: 10 });

  setup.step(function () {
    for (var i=0; i<10; i++) {
      request.get('http://localhost:3003/ok1', function () {});
      request.get('http://localhost:3003/ok2', function () {});
    }
  });

  // should be even distrubution
  setup.step(function () {
    test.equal(server1.counts.ok, 10);
    test.equal(server2.counts.ok, 10);
  });

  setup.step(function () {
    server1.close();
    server2.close();
    front.stop();
    test.done();
  });
};
