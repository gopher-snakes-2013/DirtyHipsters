require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv'
require 'soundcloud'

Dotenv.load(".env")

set :database, 'sqlite:///dev.db'
enable :sessions


get '/' do
  if session[:user_token]
    @client = Soundcloud.new(:access_token => session[:user_token])
    @tracks= @client.get('/me/tracks')
    p @following = @client.get('/me/followings')

    erb :index
  else
    erb :login
  end
end

get '/login' do
  # create client object with app credentials
  client = Soundcloud.new(:client_id => ENV['SOUNDCLOUD_ID'],
                        :client_secret => ENV['SOUNDCLOUD_SECRET'],
                        :redirect_uri => 'http://localhost:9393/auth')

  redirect client.authorize_url()
end

get '/auth' do
  client = Soundcloud.new(:client_id => ENV['SOUNDCLOUD_ID'],
                        :client_secret => ENV['SOUNDCLOUD_SECRET'],
                        :redirect_uri => 'http://localhost:9393/auth')
  access_token = client.exchange_token(:code => params[:code]).access_token
  session[:user_token] = access_token
  redirect '/'
end
