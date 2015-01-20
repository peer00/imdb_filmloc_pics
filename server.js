var express = require('express');
var ejs = require('ejs');
var bodyParser = require('body-parser');

var app = express();
app.use(bodyParser.urlencoded({extended: true}));

var items = []

app.get('/', function(req, res) {
  // items will be empty the first time
  // this method is called
  res.render('index.ejs', { array: items });
});

app.post('/add', function(req, res) {
  // note that we're using req.body.item
  // rather than req.params.item or
  // req.query.item

  var person = {
    first: "",
    last: "",
    email: "",
  };

  person.first = req.body.first;
  person.last = req.body.last;
  person.email = req.body.email;
  items.push(person);

  res.render('index.ejs', { array: items });
})

app.listen(3000);

console.log('listening on port 3000!');
