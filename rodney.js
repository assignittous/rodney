#!/usr/bin/env node
var config, help, inquirer, logger, noOp, pkg, program, result, subcommand;

require('sugar');

pkg = require('./package.json');

program = require('commander');

logger = require('./lib/logger').Logger;

inquirer = require("inquirer");

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
      "default": "bye"
    }
  ];
  quit = false;
  ask = function() {
    if (!quit) {
      return inquirer.prompt(prompt, function(response) {
        if (["quit", "exit", "bye"].any(response.request.toLowerCase())) {
          return quit = true;
        } else {
          console.log(response.request);
          return ask();
        }
      });
    } else {
      return console.log("QUIT");
    }
  };
  return ask();
});

result = program.parse(process.argv);