
/*

 * Data

Utility functions for outputting cloud data to files
 */
var convert, fs, logger;

fs = require('fs-extra');

logger = require('../lib/logger').Logger;

convert = require('../lib/convert').Convert;

exports.Data = {
  checkPath: function(path) {},
  toCsv: function(path, data, attributes, transformFunction) {
    return fs.outputFileSync(path, convert.arrayToCsv(data, attributes));
  },
  toXlsx: function(path, data, attributes, transformFunction) {},
  toXml: function(path, data, attributes, transformFunction) {}
};
