var poise = require('./index');

export class Builder {
  function run(config) {
    ret = {};
    if (config.http)
      ret.http = this.parseHTTP(config.http);

    if (config.tcp)
      ret.tcp  = this.parseTCP(config.tcp);

    return ret;
  }

  function parseHTTP(config) {
    var http = poise.http();
    for (var k in config) this.parseHTTPFront(http, k, config[k]);
    return http; 
  }


  function parseTCP(config) {
    var tcp = poise.tcp();
  }

}
