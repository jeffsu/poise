var setup  = require('./setup');
var poised = require('../');
var request = require('request');

module.exports['test http get proxy'] = function (test, assert) {
  var server = setup.http(); 
  server.listen(3001);

  var front = poised.http().front('main');
  var back  = front.back('main');
  back.server('3001', 'http://localhost:3001');

  setup.step(function () {
    request.get('http://localhost:3001/ok', function (err, res, body) {
      assert.equal(res.statusCode, 200);
      assert.equal(server._count, 1);
    });
  });

  setup.step(function () {
    request.get('http://localhost:3001/notok', function (err, res, body) {
      server.close();
      assert.equal(res.statusCode, 500);
      assert.equal(server._count, 2);
      test.finish();
    });
  });

};

module.exports['test http post proxy'] = function (test, assert) {
  var server = setup.http(); 
  server.listen(3001);

  var front = poised.http().front('main');
  var back  = front.back('main');
  back.server('3001', 'http://localhost:3001');

  setup.step(function () {
    request.post({ uri: 'http://localhost:3001/ok', body: 'foo' }, function (err, res, body) {
      server.close();
      assert.equal(body, 'foo');
      assert.equal(server._count, 1);
      test.finish();
    });
  });


};
