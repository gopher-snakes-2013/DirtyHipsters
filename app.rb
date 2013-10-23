require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv'
require 'soundcloud'
require_relative 'helpers/soundcloud_helper'

Dotenv.load(".env")

set :database, 'sqlite:///dev.db'
enable :sessions



helpers do

include SoundCloudHelper

  def logged_in?
      session[:user_token]
  end

end


get '/' do
  if logged_in?
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
  client_access_token(params[:code])
  redirect '/'
end

get '/soundcloud'do
  redirect "http://www.soundcloud.com"
end

get '/logout' do
  session.clear
  redirect "http://soundcloud.com"
end
