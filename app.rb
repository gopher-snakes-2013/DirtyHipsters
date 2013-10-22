require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv'
require 'soundcloud'

Dotenv.load(".env")

set :database, 'sqlite:///dev.db'
enable :sessions

def client_creator
  client = Soundcloud.new(:client_id => ENV['SOUNDCLOUD_ID'],
                        :client_secret => ENV['SOUNDCLOUD_SECRET'],
                        :redirect_uri => 'http://localhost:9393/auth')
end

get '/' do
  if session[:user_token]
    @client = Soundcloud.new(:access_token => session[:user_token])
    @tracks= @client.get('/me/tracks')
    @following = @client.get('/me/followings')

    erb :index
  else
    erb :login
  end
end

get '/login' do
  # create client object with app credentials
  client = client_creator
  redirect client.authorize_url()
end

get '/auth' do
  client = client_creator
  access_token = client.exchange_token(:code => params[:code]).access_token
  session[:user_token] = access_token
  redirect '/'
end

get '/soundcloud'do
  redirect "http://www.soundcloud.com"
end

get '/logout' do
  session.clear
  redirect "http://soundcloud.com"
end
