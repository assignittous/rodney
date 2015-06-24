var exports;

exports = {
  parse: function(query) {
    var ACCESS_TOKEN;
    console.log("wit says hi");
    ACCESS_TOKEN = configuration.current.token;
    return wit.captureTextIntent(ACCESS_TOKEN, query, function(err, res) {
      console.log('Response from Wit for text input: ');
      if (err) {
        console.log('Error: ', err);
      }
      console.log(JSON.stringify(res, null, ' '));
    });
  }
};
