require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv'
require 'soundcloud'

Dotenv.load(".env")

LOCAL_DATABASE_LOCATION = 'sqlite:///dev.db'

set :database, LOCAL_DATABASE_LOCATION
enable :sessions

def client_creator
  client = Soundcloud.new(:client_id => ENV['SOUNDCLOUD_ID'],
                        :client_secret => ENV['SOUNDCLOUD_SECRET'],
                        :redirect_uri => 'http://localhost:9393/auth')
end

def set_active_user(token)
  session[:user_token] = token
end

def logged_in?
  session[:user_token] ? true : false
end

def cached_user_token
  session[:user_token]
end

get '/' do
  if logged_in?
    @client = Soundcloud.new(:access_token => cached_user_token)
    @tracks= @client.get('/me/tracks')
    @following = @client.get('/me/followings')
    @username = @client.get('/me').username
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
# Should this be a post request instead?
  client = client_creator
  # Do you need to create client in both routes?
  access_token = client.exchange_token(:code => params[:code]).access_token
  set_active_user(access_token)
  redirect '/'
end


get '/logout' do
  session.clear
  # why not redirect to your app?
  redirect "http://soundcloud.com"
end
