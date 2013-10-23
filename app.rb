require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv'
require 'soundcloud'
require './soundcloud_helper'

Dotenv.load(".env")

set :database, 'sqlite:///dev.db'
enable :sessions
helpers do
  include SoundCloudHelper
end

get '/' do
  if logged_in?
    fetch_soundcloud_tracks_and_followings
    erb :index
  else
    erb :login
  end
end

get '/login' do
  soundcloud_authorization
end

get '/auth' do
  set_session_user_token
  redirect '/'
end

get '/soundcloud'do
  soundcloud_redirect
end

get '/logout' do
  session.clear
  soundcloud_redirect
end
