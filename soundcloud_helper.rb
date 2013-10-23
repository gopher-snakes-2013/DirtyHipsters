module SoundCloudHelper
    def client_creator
      client = Soundcloud.new(:client_id => ENV['SOUNDCLOUD_ID'],
                            :client_secret => ENV['SOUNDCLOUD_SECRET'],
                            :redirect_uri => 'http://localhost:9393/auth')
    end

    def fetch_soundcloud_tracks_and_followings
        @client = Soundcloud.new(:access_token => session[:user_token])
        @tracks= @client.get('/me/tracks')
        @following = @client.get('/me/followings')
    end

    def logged_in?
      session[:user_token]
    end

    def set_session_user_token
      client = client_creator
      access_token = client.exchange_token(:code => params[:code]).access_token
      session[:user_token] = access_token
    end

    def soundcloud_authorization
      client = client_creator
      redirect client.authorize_url()
    end

    def soundcloud_redirect
      redirect "http://www.soundcloud.com"
    end

  end