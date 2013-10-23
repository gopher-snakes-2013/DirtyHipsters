require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv'
require 'soundcloud'

Dotenv.load(".env")

set :database, 'sqlite:///dev.db'
enable :sessions

def logged_in?
  session[:user_token] ? true : false
end

def active_user
  @client ||= Soundcloud.new(:access_token => session[:user_token])
end

def user_profile_info(user)
  @user_tracks= user.get('/me/tracks')
  @following_others = user.get('/me/followings')
end

def client_creator
  new_client = Soundcloud.new(:client_id => ENV['SOUNDCLOUD_ID'],
                        :client_secret => ENV['SOUNDCLOUD_SECRET'],
                        :redirect_uri => 'http://localhost:9393/auth')
end


get '/' do
  if logged_in?
    user_profile_info(active_user)
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
  session[:user_token] = client_creator.exchange_token(:code => params[:code]).access_token
  redirect '/'
end

get '/soundcloud'do
  redirect "http://www.soundcloud.com"
end

get '/logout' do
  session.clear
  redirect "http://soundcloud.com"
end
