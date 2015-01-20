require "HTTParty"
require "uri"
require "pry"
require "json"
require "sinatra"

picsArray = []

lat = 40.744708
lon = -73.986336

pictures = HTTParty.get("https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=97cad31e7df16556561d7f03e2d76a47&content_type=1&geo_context=2&lat=#{lat}&lon=#{lon}&radius=5&radius_units=km&format=json&nojsoncallback=1")

pictures_parsed = JSON.parse(pictures.body)

for pics in pictures_parsed["photos"]["photo"] do
  picsArray.push("https://farm#{pics["farm"]}.staticflickr.com/#{pics["server"]}/#{pics["id"]}_#{pics["secret"]}.jpg")
end

get '/' do
  erb :flickr, locals: {picsArray: picsArray}
end
