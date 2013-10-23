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
    #this is how dirtyhipster knows who's logged in
    @client = Soundcloud.new(:access_token => session[:user_token])
    @my_favorites= @client.get('/me/favorites')
    @favorites_ids = []

    #grab track id of each favorite
    @my_favorites.each do |favorite|
      @favorites_ids << favorite.id
    end

    if session[:searched_user_id]

    end

    #dynamic playlist creation
    # @favorites_ids.map! { |id| {:id => id} }
    # @client.post('/playlists', :playlist => {
    #   :title => 'Favorites',
    #   :sharing => 'public',
    #   :tracks => @favorites_ids
    # })



    #grab people that you're following
    @following = @client.get('/me/followings')
    @following_ids = []

    #push following's ids into array
    @following.each do |followee|
      @following_ids << followee.id
    end

    #grabs uri for the iframe widget
    @last_playlist_uri = @client.get('/me/playlists').last.uri
    erb :index
  else
    erb :login
  end
end

post '/search' do
  client = client_creator
  #searches through soundcloud for us
  search_term = params[:query]
  searched_users_array = client.get('/users', :q => search_term)
  searched_users_array.each do |user|
    if user.username == search_term
      session[:searched_user_id] = user.id
    end
  end
  redirect '/'
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
