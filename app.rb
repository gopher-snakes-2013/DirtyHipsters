require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv'
require 'soundcloud'

Dotenv.load(".env")

set :database, 'sqlite:///dev.db'
enable :sessions

helpers do
  def client_creator
    client = Soundcloud.new(:client_id => ENV['SOUNDCLOUD_ID'],
      :client_secret => ENV['SOUNDCLOUD_SECRET'],
      :redirect_uri => 'http://localhost:9393/auth')
  end

  def logged_in?
    session[:user_token] != nil
  end

  def set_active_client(user_token)
    Soundcloud.new(:access_token => user_token)
  end

  def collect_client_favorited_tracks
    @client.get('/me/favorites') 
  end

  def populate_favorites_ids
    @favorites.each do |favorite|
      @favorites_ids << favorite.id
    end
  end

  def make_fav_ids_array_of_hashes
    @favorites_ids.map! { |id| {:id => id} }
  end

  def get_client_username(client)
    client.get('/me').username 
  end

  def post_new_playlist(client)
    client.post('/playlists', :playlist => {
      :title => 'Favorites',
      :sharing => 'private',
      :tracks => @favorites_ids
      })
  end
end

get '/' do
  if logged_in?
    #this is how dirtyhipster knows who's logged in
    @client = set_active_client(session[:user_token])
    @favorites= collect_client_favorited_tracks
    @favorites_ids = []

    #grab track id of each favorite
    populate_favorites_ids

    #dynamic playlist creation
    make_fav_ids_array_of_hashes
    post_new_playlist(@client)

    #searches through soundcloud for user
    @searched_users_array = @client.get('/users', :q => 'trostli')

    #iterate through that array to grab exact username match
    @searched_users_array.each do |user|
      if user.username == 'trostli'
        p user.id
      end
    end

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
