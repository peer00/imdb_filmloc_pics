require "HTTParty"
require "uri"
require "pry"
require "json"
require "sinatra"

movieArray = []

moviesObjects = []

File.open("run.sh", "w")

File.open("movies.txt", "r") do |movie|
  while line = movie.gets
    movieArray.push(line.chomp)
  end
  #p movieArray
end

for movie in movieArray do
  p "1"
  if movie.include?"("
    movie2 = movie.slice(0...movie.index("(")).strip!
    moviesObjects.push( JSON.parse( HTTParty.get("http://www.myapifilms.com/imdb?title="+URI.encode(movie2)+"&format=JSON") ) )
  else
    moviesObjects.push( JSON.parse ( HTTParty.get("http://www.myapifilms.com/imdb?title="+URI.encode(movie)+"&format=JSON") ) )
  end
end

for object in moviesObjects do
  #binding.pry
  p "2"
  location = object[0]["filmingLocations"].join(" ")
  #p location

  if location == ""
    object[0]["location"] = "NO_LOCATION"
    #p object[0]["location"]
  else
    object[0]["location"] = location
    #p object[0]["location"]
  end

end


for object in moviesObjects do
  p "3"
  unless object[0]["location"] == "NO_LOCATION"
    latlong = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=" + URI.encode(object[0]["location"]) + "&key=AIzaSyCyoQZYmPdbY3Z6Ty-3_hX7TPPwBMiiaM0")
    latlong_parsed = JSON.parse(latlong.body)
    if latlong_parsed["results"][0] != nil
      object[0]["lat"] = latlong_parsed["results"][0]["geometry"]["location"]["lat"] #later opslaan in goede locatie
      object[0]["lng"] = latlong_parsed["results"][0]["geometry"]["location"]["lng"] #later opslaan in goede locatie
    elsif latlong_parsed["results"][1] != nil
      object[0]["lat"] = latlong_parsed["results"][1]["geometry"]["location"]["lat"] #later opslaan in goede locatie
      object[0]["lng"] = latlong_parsed["results"][1]["geometry"]["location"]["lng"] #later opslaan in goede locatie
    end
  end
  #p object
end

for object in moviesObjects do
  p "4"
  object[0]["picsArray"] = []


  pictures = HTTParty.get("https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=97cad31e7df16556561d7f03e2d76a47&content_type=1&geo_context=2&lat=#{object[0]["lat"].to_s}&lon=#{object[0]["lng"].to_s}&radius=10&radius_units=km&format=json&nojsoncallback=1")
  #binding.pry
  pictures_parsed = JSON.parse(pictures.body)
  p pictures_parsed
  #binding.pry

  unless pictures_parsed["stat"] == "fail"
    for pics in pictures_parsed["photos"]["photo"] do
      object[0]["picsArray"].push("https://farm#{pics["farm"]}.staticflickr.com/#{pics["server"]}/#{pics["id"]}_#{pics["secret"]}.jpg")
    end
  end
end


get '/' do
  p "5"
  #binding.pry
  erb :index, locals: {moviesObjects: moviesObjects}
end
