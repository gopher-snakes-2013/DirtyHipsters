describe Client do
  describe 'call_api' do
     it "gets a response from an api" do
       VCR.use_cassette 'model/api_response' do
          response = call_api(https://api.soundcloud.com/playlists/12996949)
          response.first.should == 'hello world'
       end
     end
  end
end