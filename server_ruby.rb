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
  if movie.include?"("
    movie2 = movie.slice(0...movie.index("(")).strip!
    moviesObjects.push( JSON.parse( HTTParty.get("http://omdbapi.com?t=" + URI.encode(movie2)) ) )
  else
    moviesObjects.push( JSON.parse ( HTTParty.get("http://omdbapi.com?t=" + URI.encode(movie)) ) )
  end
end

for object in moviesObjects do
  locations = %x(curl http://www.imdb.com/title/#{object["imdbID"]}/locations | pup \"dt a text{}\")
  locations.chomp.split("\n").reject! { |elem| elem.empty? }

  if locations != ""
    object["locations"] = locations
    p object["locations"]
  else
    object["locations"] = "NO_LOCATION"
    p object["locations"]
  end

end


for object in moviesObjects do
  unless object["locations"] == "NO_LOCATION"
    latlong = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=" + URI.encode(object["locations"][0]) + "&key=AIzaSyCyoQZYmPdbY3Z6Ty-3_hX7TPPwBMiiaM0")
    latlong_parsed = JSON.parse(latlong.body)

    unless latlong_parsed["results"][1] == nil
      object["lat"] = latlong_parsed["results"][1]["geometry"]["location"]["lat"] #later opslaan in goede locatie
      object["lng"] = latlong_parsed["results"][1]["geometry"]["location"]["lng"] #later opslaan in goede locatie
    end
  end
  #p object
end

for object in moviesObjects do
  object["picsArray"] = []
  lat = object["lat"].round(5)
  lng = object["lnd"].round(5)
  p lat
  p lng
  pictures = HTTParty.get("https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=97cad31e7df16556561d7f03e2d76a47&content_type=1&geo_context=2&lat=#{lat}&lon=#{lng}&radius=5&radius_units=km&format=json&nojsoncallback=1")

  pictures_parsed = JSON.parse(pictures.body)

  unless pictures_parsed["stat"] == "fail"
    for pics in pictures_parsed["photos"]["photo"] do
      object["picsArray"].push("https://farm#{pics["farm"]}.staticflickr.com/#{pics["server"]}/#{pics["id"]}_#{pics["secret"]}.jpg")
    end
  end
end


get '/' do
  erb :index, locals: {moviesObjects: moviesObjects}
end
