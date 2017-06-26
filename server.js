var express = require('express');
var app = express();
var path = require('path');

// Make files in /static accessible
app.use('/static', express.static(__dirname + '/static'));
// Make bower_components accessible
app.use('/node_modules',  express.static(__dirname + '/node_modules'));

// viewed at http://localhost:5000
app.get('/', function(req, res) {
  res.sendFile(path.join(__dirname + '/index.html'));
});

app.get('', function(req, res) {
  res.sendFile(path.join(__dirname + '/index.html'));
});

app.set('port', (process.env.PORT || 8081));

app.listen(app.get('port'), function() {
  console.log('Node app is running on port', app.get('port'));
});
