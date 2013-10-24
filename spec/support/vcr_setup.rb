VCR.configure do |c|
  #directory where cassettes will be saved
  c.cassette_library_dir = 'spec/vcr'
  #HTTP request service
  c.hook_into :typhoeus
end