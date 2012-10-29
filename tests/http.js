var setup  = require('./setup');
var poised = require('../');
var request = require('request');

module.exports['test http get proxy'] = function (test, assert) {
  var server = setup.http(); 
  server.listen(3001);

  var front = poised.http().front('main');
  front.listen(3002);

  var back  = front.back('main');
  back.server('3001', 'http://localhost:3001');

  setup.step(function () {
    request.get('http://localhost:3002/ok', function (err, res, body) {
      assert.equal(res.statusCode, 200);
      assert.equal(server.counts.ok, 1);
    });
  });

  setup.step(function () {
    request.get('http://localhost:3002/error', function (err, res, body) {
      assert.equal(res.statusCode, 500);
      assert.equal(server.counts.errors, 1);
    });
  });

  setup.step(function () {
    server.close();
    front.stop();
    test.finish();
  });
};

module.exports['test http post proxy'] = function (test, assert) {
  var server = setup.http(); 
  server.listen(3001);

  var front = poised.http().front('main');
  front.listen(3002);

  var back  = front.back('main');
  back.server('3001', 'http://localhost:3001');

  setup.step(function () {
    request.post({ uri: 'http://localhost:3002/ok', body: 'foo' }, function (err, res, body) {
      assert.equal(body, 'foo');
      assert.equal(server.counts.ok, 1);
    });
  });

  setup.step(function () {
    front.stop();
    server.close();
    test.finish();
  });
};
