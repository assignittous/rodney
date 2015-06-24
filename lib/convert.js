
/*

 * Convert

conversion functions
 */
var CSON, fs, logger;

require('sugar');

fs = require('fs');

logger = require('../lib/logger.js').Logger;

CSON = require('cson');

exports.Convert = {
  csvHeader: function(object) {
    var header;
    if (Array.isArray(object)) {
      header = object.map(function(x) {
        return '"' + x + '"';
      });
    } else {
      header = Object.keys(object).map(function(x) {
        return '"' + x + '"';
      });
    }
    return header;
  },
  csvRowSanitize: function(object, attributes) {
    if (attributes != null) {
      object = Object.select(object, attributes);
    }
    return Object.values(object).map(function(x) {
      var out;
      if (isNaN(x)) {
        out = "\"" + (x.replace(/\"/g, '\"\"')) + "\"";
        return out;
      } else {
        return x;
      }
    });
  },
  objectToCsv: function(data) {
    var targetRecords;
    targetRecords = this.csvHeader(data) + '\n';
    return targetRecords += this.csvRowSanitize(data);
  },
  arrayToCsv: function(data, attributes) {
    var targetRecords, that;
    that = this;
    targetRecords = this.csvHeader(attributes || data.first()) + '\n';
    data.each(function(o) {
      return targetRecords += that.csvRowSanitize(o, attributes) + "\n";
    });
    return targetRecords;
  },
  fileExtension: function(path) {
    var elements;
    elements = path.split('.');
    return elements.last();
  },
  file: function(sourcePath, targetPath) {
    var sanitized, sourceRecords, targetRecords;
    switch (this.fileExtension(sourcePath)) {
      case 'csv':
        console.log('csv');
        break;
      case 'cson':
      case 'json':
        console.log('cson/json');
        sourceRecords = CSON.parseFile(sourcePath);
        break;
      case 'xml':
        console.log('xml');
    }
    switch (this.fileExtension(targetPath)) {
      case 'csv':
        sanitized = Object.keys(sourceRecords.first()).map(function(x) {
          return '"' + x + '"';
        });
        targetRecords = sanitized.join(',') + '\n';
        sourceRecords.each(function(o) {
          sanitized = Object.values(o).map(function(x) {
            var out;
            if (isNaN(x)) {
              console.log("-----------------------");
              out = "\"" + (x.replace(/\"/g, '\"\"')) + "\"";
              console.log(x);
              console.log;
              console.log(out);
              return out;
            } else {
              return x;
            }
          });
          return targetRecords = targetRecords + sanitized.join(',') + '\n';
        });
        console.log('csv');
        break;
      case 'cson':
        console.log('cson');
        targetRecords = CSON.createCSONString(sourceRecords);
        break;
      case 'json':
        console.log('json');
        targetRecords = CSON.createJSONString(sourceRecords);
        break;
      case 'xml':
        console.log('xml');
        break;
      default:
        targetRecords = null;
    }
    if (targetRecords != null) {
      console.log(targetRecords);
      return fs.writeFileSync(targetPath, targetRecords);
    }
  },
  dateSid: function() {
    return Date.create().format("{yyyy}{MM}{dd}{HH}{mm}{ss}{fff}");
  },
  checkExtension: function(path, ext) {
    if (path.endsWith(ext)) {
      return path;
    } else {
      return path + "." + ext;
    }
  },
  xmlToJade: function(path, jadePath) {
    var fileContents, lines, regexes;
    logger.info("xmltojade");
    fileContents = fs.readFileSync(path, {
      encoding: 'utf8'
    });
    fileContents = fileContents.replace('<?xml version="1.0" encoding="UTF-8" standalone="no"?>', "");
    regexes = [];
    regexes.push({
      name: "Strip close tags",
      regex: new RegExp("</(.*?)>", "g"),
      replacement: ""
    });
    regexes.push({
      name: "Close empty elements",
      regex: new RegExp("/>", "g"),
      replacement: ">"
    });
    regexes.push({
      name: "Convert to jade",
      regex: new RegExp("<(.*?) (.*)>", "g"),
      replacement: "$1($2)"
    });
    regexes.push({
      name: "Comma separate attributes",
      regex: new RegExp('" (.*?=)', "g"),
      replacement: '", $1'
    });
    regexes.push({
      name: "Set tabs to 2 spaces",
      regex: new RegExp('    ', "g"),
      replacement: '  '
    });
    regexes.each(function(o) {
      logger.info(o.name);
      return fileContents = fileContents.replace(o.regex, o.replacement);
    });
    fileContents = '<?xml version="1.0" encoding="UTF-8"?>\n' + fileContents;
    lines = fileContents.split('\n');
    fileContents = '';
    lines.each(function(line) {
      if (!line.isBlank()) {
        return fileContents += line + '\n';
      }
    });
    logger.info("Strip blank lines");
    fs.writeFileSync(jadePath, fileContents);
    return logger.info("Wrote to " + jadePath);
  },
  xmlTidy: function(path, jadePath) {
    var cleansed, fileContents, regex;
    fileContents = fs.readFileSync(path, {
      encoding: 'utf8'
    });
    regex = new RegExp("<(.*?) (.*)/>", "g");
    cleansed = fileContents.replace(regex, "<$1 $2></$1>");
    return fs.writeFileSync(jadePath, cleansed);
  },
  deleteFileIfExists: function(path) {
    var e;
    try {
      fs.openSync(path, 'r');
      fs.unlinkSync(path);
      return logger.info("Deleted " + path);
    } catch (_error) {
      e = _error;
      return console.log("can't open");
    } finally {
      console.log("finally");
    }
  }
};
