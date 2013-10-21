require 'sinatra'
require 'sinatra/activerecord'
require 'dotenv'

Dotenv.load(".env")

set :database, ENV['DATABASE_URL'] || 'postgres://localhost/App'

enable :sessions

get '/' do
  erb :index
end