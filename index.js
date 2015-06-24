var ask, inquirer, prompt, quit;

inquirer = require("inquirer");

require('sugar');

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

ask();
