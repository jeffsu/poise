var setup  = require('./setup');
var poised = require('../');
var request = require('request');

module.exports['test http roundrobin'] = function (test, assert) {
  var server1 = setup.http(); 
  server1.listen(3001);

  var server2 = setup.http(); 
  server2.listen(3002);

  var front = poised.http().front('main');
  front.listen(3003);

  var back = front.back('main');

  back.server('3001', 'http://localhost:3001').health('http://localhost:3001/health', { interval: 10 });
  back.server('3002', 'http://localhost:3002').health('http://localhost:3002/health', { interval: 10 });

  setup.step(function () {
    for (var i=0; i<10; i++) 
      request.get('http://localhost:3003/ok', function () {});
  });

  // should be even
  setup.step(function () {
    assert.equal(server1.counts.ok, 5);
    assert.equal(server2.counts.ok, 5);
  });

  setup.step(function () {
    server1.close();
    server2.close();
    front.stop();
    test.finish();
  });
};

module.exports['test http roundrobin failover'] = function (test, assert) {
  setup.reset();

  var server1 = setup.http(); 
  server1.listen(3001);

  var server2 = setup.http(); 
  server2.listen(3002);

  var front = poised.http().front('main');
  front.listen(3003);

  var back = front.back('main');
  back.server('3001', 'http://localhost:3001').health('http://localhost:3001/health', { interval: 10 });
  back.server('3002', 'http://localhost:3002').health('http://localhost:3002/health', { interval: 10 });

  setup.step(function () {
    for (var i=0; i<10; i++) 
      request.get('http://localhost:3003/ok', function () {});
  });

  // should be even
  setup.step(function () {
    assert.equal(server1.counts.ok, 5);
    assert.equal(server2.counts.ok, 5);
  });

  setup.step(function () {
    server2.close();
  });


  setup.step(function () {
    for (var i=0; i<10; i++) 
      request.get('http://localhost:3003/ok', function () {});
  });

  // should be even
  setup.step(function () {
    assert.equal(server1.counts.ok, 15);
    assert.equal(server2.counts.ok, 5);
  });

  setup.step(function () {
    server1.close();
    front.stop();
    test.finish();
  });
};

