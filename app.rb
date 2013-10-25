require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv'
require 'soundcloud'

Dotenv.load(".env")

set :database, 'sqlite:///dev.db'
enable :sessions

CLIENT = ""

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

  def post_new_playlist(client, track_ids, query)
    client.post('/playlists', :playlist => {
      :title => 'DirtyHipster.co - ' + query + ' inspired playlist',
      :sharing => 'public',
      :tracks => track_ids
      })
  end

  def grab_hipster_filter_val(value)
    case value
    when "clean"
      fav_max_num = 50000
    when "scruffy"
      fav_max_num = 5000
    when "dirty"
      fav_max_num = 1000
    end
    return fav_max_num
  end

  def filter_favs_by_fav_count(fav_array, fav_max_count)
    filtered_favs = []
    fav_array.each do |favorite|
      if favorite.favoritings_count < fav_max_count
        filtered_favs << favorite
      end
    end
    return filtered_favs
  end

end

get '/' do
  if logged_in?
    #this is how dirtyhipster knows who's logged in
    @client = set_active_client(session[:user_token])
    client_favorites_ids = grab_favorites_ids(collect_client_favorited_tracks)

    #dynamic playlist creation
    fav_ids_array_of_hashes = make_fav_ids_array_of_hashes(client_favorites_ids)
    post_new_playlist(@client, fav_ids_array_of_hashes, get_client_username(@client))

    if search_submitted?
      user_favs = collect_user_favorited_tracks(session[:searched_user_id])
      filtered_favs = filter_favs_by_fav_count(user_favs, session[:max_fav_count])
      user_favs_ids = grab_favorites_ids(filtered_favs)
      track_ids = make_fav_ids_array_of_hashes(user_favs_ids)
      post_new_playlist(@client, track_ids, session[:query])
    end

    #grabs uri for the iframe widget
    @last_playlist_uri = @client.get('/me/playlists').first.uri
    erb :index
  else
    erb :login
  end
end

post '/search' do
  client = client_creator

  #grabs value from hipster filter
  max_fav_count = grab_hipster_filter_val(params[:filter])
  session[:max_fav_count] = max_fav_count

  #searches through soundcloud for us
  search_term = params[:query]
  session[:query] = params[:query]

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
