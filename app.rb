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

  def search_submitted?
    session[:searched_user_id] != nil
  end

  def set_active_client(user_token)
    Soundcloud.new(:access_token => user_token)
  end

  def collect_client_favorited_tracks
    @client.get('/me/favorites')
  end

  def collect_user_favorited_tracks(user_id)
    @client.get("/users/#{user_id}/favorites")
  end

  def grab_favorites_ids(favorite_array)
    favorites_ids = []
    favorite_array.each do |favorite|
      favorites_ids << favorite.id
    end
    return favorites_ids
  end

  def make_fav_ids_array_of_hashes(favorites_ids)
    favorites_ids.map! { |id| {:id => id} }
  end

  def get_client_username(client)
    client.get('/me').username
  end

  def post_new_playlist(client, track_ids)
    client.post('/playlists', :playlist => {
      :title => 'Favorites',
      :sharing => 'public',
      :tracks => track_ids
      })
  end
end

get '/' do
  if logged_in?
    #this is how dirtyhipster knows who's logged in
    @client = set_active_client(session[:user_token])
    client_favorites_ids = grab_favorites_ids(collect_client_favorited_tracks)

    #dynamic playlist creation
    fav_ids_array_of_hashes = make_fav_ids_array_of_hashes(client_favorites_ids)
    post_new_playlist(@client, fav_ids_array_of_hashes)

    if search_submitted?
      user_favs = collect_user_favorited_tracks(session[:searched_user_id])
      user_favs_ids = grab_favorites_ids(user_favs)
      track_ids = make_fav_ids_array_of_hashes(user_favs_ids)
      post_new_playlist(@client, track_ids)
    end

    #grabs uri for the iframe widget
    @last_playlist_uri = @client.get('/me/playlists').first.uri
    puts @last_playlist_uri
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
