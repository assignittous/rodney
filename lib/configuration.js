var CSON, cwd;

CSON = require('cson');

cwd = process.env.PWD || process.cwd();

exports.Configuration = {
  current: {},
  dictionary: {},
  entities: {},
  cwd: function() {
    return process.env.PWD || process.cwd();
  },
  load: function() {
    this.current = CSON.parseCSONFile((this.cwd()) + "/config.rodney.cson");
    this.dictionary = CSON.parseCSONFile((this.cwd()) + "/config.rodney.dictionary.cson");
    return this.entities = CSON.parseCSONFile((this.cwd()) + "/config.rodney.entities.cson");
  },
  init: function() {
    console.log("init");
    this.load();
    return this;
  }
}.init();
