#!/usr/bin/env node
var CSON, config, cwd, help, inquirer, logger, noOp, pkg, program, result, rodney, subcommand;

require('sugar');

pkg = require('./package.json');

program = require('commander');

logger = require('./lib/logger').Logger;

inquirer = require("inquirer");

CSON = require('cson');

cwd = process.env.PWD || process.cwd();

rodney = require('./lib/rodney').Rodney;

noOp = function() {
  return console.log("Nothing ran, couldn't understand your command");
};

program.version(pkg.version, '-v, --version');

subcommand = {};

config = program.command('config');

config.description('Create a new thing');

config.action(function() {
  return console.log("This command dumps the configuration");
});

help = program.command('help');

help.description('Create a new thing');

help.action(function() {
  return console.log(help);
});

subcommand.init = program.command('init');

subcommand.init.description('Initialize knodeo for the current working folder');

subcommand.init.action(function() {});

subcommand.console = program.command('console');

subcommand.console.action(function() {
  var ask, prompt, quit;
  prompt = [
    {
      type: 'input',
      name: 'request',
      message: 'Say Something to Rodney',
      "default": "Send me last year's income statement"
    }
  ];
  quit = false;
  ask = function() {
    if (!quit) {
      return inquirer.prompt(prompt, function(response) {
        if (["quit", "exit", "bye"].any(response.request.toLowerCase())) {
          return quit = true;
        } else {
          rodney.parse(response.request);
          return ask();
        }
      });
    } else {
      return console.log("QUIT");
    }
  };
  return ask();
});

subcommand.batch = program.command('batch');

subcommand.batch.action(function() {
  var batch;
  batch = CSON.parseCSONFile(cwd + "/samples.cson");
  console.log(batch);
  return batch.each(function(item) {
    return rodney.parse(item);
  });
});

result = program.parse(process.argv);
