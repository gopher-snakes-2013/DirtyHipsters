module SoundCloudHelper

 def active_user
    @client ||= Soundcloud.new(:access_token => session[:user_token])
  end

  def user_tracks
    @user_tracks ||=  active_user.get('/me/tracks')
  end

  def following_others
    @following_others ||= active_user.get('/me/followings')
  end


  def client_creator
    new_client = Soundcloud.new(:client_id => ENV['SOUNDCLOUD_ID'],
                          :client_secret => ENV['SOUNDCLOUD_SECRET'],
                          :redirect_uri => 'http://localhost:9393/auth')
  end

  def client_access_token(session_code)
    session[:user_token] = client_creator.exchange_token(:code => session_code).access_token
  end

end
