require 'sinatra'

items = []

get '/' do
  erb(:index, locals: {array: items}) # no items yet
end

post '/add' do

  person = {
    :first => "",
    :last => "",
    :email => "",
  }

  person[:first] = params[:first]
  person[:last] = params[:last]
  person[:email] = params[:email]

  items.push(person)

  erb(:index, locals: {array: items})
end
