require 'sinatra'
require 'sinatra/authlane'

set :sessions, true

# The basic setup of AuthLane only requires the `auth` strategy, which
# is responsible for signing in users.
#
Sinatra::AuthLane.create_auth_strategy do
  { id: 1 } if params[:user] == 'Frank' and params[:pass] == 'authlane'
end

get '/' do
  <<-DOC
    <form method="post" action="/auth">
    <input type="test" name="user" value="Frank" />
    <input type="password" name="pass" value="authlane" />
    <input type="submit" value="Sign in" />
    </form>
  DOC
end

post '/auth' do
  authorize!
  redirect '/user'
end

get '/unauth' do
  unauthorize!
  redirect '/'
end

get '/user' do
  protect!
  'Super secret stuff!<br /><a href="/unauth">Sign out</a>'
end

# Note: This route must match with the AuthLane configuration
# for failed authorizations. It is the page that is displayed,
# when someone unauthorized tries to access a protected route.
#
# Failed login attempts go here as well, so usually, this is
# the sign in page itself.
#
get '/user/unauthorized' do
  'Login failed. <a href="/">Try again</a>'
end
