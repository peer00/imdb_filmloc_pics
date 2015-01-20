var express = require("express");
var ejs = require("ejs");
var bodyParser = require("body-parser");
var fs = require("fs")
var request = require("request")
var spawn   = require('child_process').spawn;
var app = express();
app.use(bodyParser.urlencoded({extended: true}));


var top100 = function(omdb_get) {
  var movies = fs.readFileSync("movies.txt").toString().split("\n");
  var moviesArray = []

  movies.forEach(function (movie) {
    if (movie.indexOf("(") === -1) {
      moviesArray.push(movie);
    }
    else {
      moviesArray.push( movie.slice(0,movie.indexOf("(")-1 ) );
    }
  });
  console.log("ok1")
  omdb_get(true,moviesArray);
};

var omdb_get = function(cb,moviesArray) {

  console.log("ok2")

  if (cb) {
    console.log("ok3")
    var omdb_movies = [];

    moviesArray.forEach(function(movie) {
      var url = "http://omdbapi.com?t=" + encodeURI(movie);

      var omdb = request(url, function (error, response, body) {
        if (!error && response.statusCode == 200) {
          omdb_movies.push( JSON.parse(body) );

          if (moviesArray.length === omdb_movies.length) {
            console.log("ok4")
            dataToServer(omdb_movies);
          }
        }
      });
    });
  };
};



top100(omdb_get);

//imdbID


var dataToServer = function(omdb_movies) {

  //scrapen
  app.use(express.static(__dirname));


  //console.log(omdb_movies)
  var bla = 0;
  omdb_movies.forEach(function(movie) {
    if (movie.Title !== undefined) {
      var outputNew = [];
      var id = "curl http://www.imdb.com/title/" + movie.imdbID + "/locations | pup \"dt a text{}\"\n";
      movie.locationImdbUrl = id
      //console.log(movie.locationImdbUrl)
      fs.writeFileSync("run.sh", movie.locationImdbUrl);
      // fs.appendFileSync("run.sh",movie.locationImdbUrl)
      fs.chmodSync("run.sh", 0777)

      //scrapen runnen
      var command = spawn(__dirname + "/run.sh", "")
      var output  = [];

      command.stdout.on('data', function(scrape) {
        var count = 0
        output.push(scrape);
        output = output.toString().split("\n");
        output.forEach(function(entry) {
          if (entry !== "") {
            outputNew.push(entry);
          }
          else {count++}
        })
        console.log("ok5")
        movie.locations = outputNew
        bla++
        //console.log(movie.locations)
        // if (outputNew.length + count === output.length) {
        //   console.log("latlong go!")
        //   latLong(omdb_movies);
        // }

        if (bla >= omdb_movies.length) {
          console.log("latlong go!")
          latLong(omdb_movies);
        }
      })
    }
    else {bla++}
  });

}



var latLong = function(omdb_movies) {
  console.log("ok6")
  console.log(omdb_movies[0].locations)
  // omdb_movies.forEach(function(movie) {
  //   var url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + encodeURI(movie.locations[0]) + "&key=AIzaSyCyoQZYmPdbY3Z6Ty-3_hX7TPPwBMiiaM0";
  //   request(url, function (error, response, body) {
  //     if (!error && response.statusCode == 200) {
  //       data = JSON.parse(body)
  //       console.log(data);
  //       //
  //       // var lat = results[1]["geometry"]["location"]["lat"]
  //       // var lng = results[1]["geometry"]["location"]["lng"]
  //
  //     }
  //   })
  // });
}



  // https://api.instagram.com/v1/locations/search?lat=52.3747158&lng=4.8986142
  // location = data.id
  //
  // https://api.instagram.com/v1/locations/<location ID>/media/recent?access_token=749218961.1fb234f.499277cac30148f7b3fb992310567316
  // key = data.standard_resolution






  console.log("route initialized")

  app.get("/", function(req, res) {
    res.render("index2.ejs", { omdb_movies: omdb_movies, outputNew: outputNew });
  });

  app.listen(3000);
  console.log("listening on port 3000!");
