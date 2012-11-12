require('mochiscript');
var reporter = require('nodeunit').reporters.default;
reporter.run([ 'tests/http.ms', 'tests/http-balancing.ms', 'tests/resource.ms', 'tests/weighted.ms' ]);
