var URL = require('url');

class Utils {
  function parseHTTPOptions(options) {
    if (typeof options == 'string') {
      return this.setURLOptions(options);
    } else {
      var ret = { headers: {} };
      if (options.url) this.setURLOptions(options.url, ret);

      for (var k in options) 
        if (k != 'url') ret[k] = options[k];

      return ret;
    }
  }

  function setURLOptions(url, ret) {
    ret = ret || { headers: {} };

    var url = URL.parse(url);
    ret.host = url.host;
    ret.port = url.port;
    ret.path = url.path;
    ret.auth = url.auth;
   
    return ret;
  }

  function handleResponse(req, cb) {
    var cont = true;

    function ret(err, body, res) {
      if (!cont) return;
      cont = false;
      cb(err, body, res);
    }

    req.on('response', #(res) {
      var data = "";

      res.on('data',  #{ data += $1.toString() });
      res.on('end',   #{ ret(null, data, res) });
      res.on('error', #{ ret($1) });
    });

    req.on('error', #{ ret($1) });
  }
}

module.exports = new Utils();
