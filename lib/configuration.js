var CSON, cwd;

CSON = require('cson');

cwd = process.env.PWD || process.cwd();

exports.Configuration = {
  current: {},
  cwd: function() {
    return process.env.PWD || process.cwd();
  },
  load: function() {
    return this.current = CSON.parseCSONFile((this.cwd()) + "/config.rodney.cson");
  },
  init: function() {
    console.log("init");
    this.load();
    return this;
  }
}.init();
