require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/authlane'

# Defining a `remember` strategy, we can easily add a *Remember-Me* function
# to our application. Note that the token is set in the `auth` strategy.
#
class App < Sinatra::Base
  register Sinatra::AuthLane
  helpers Sinatra::Cookies

  set :sessions, true

  Sinatra::AuthLane.create_auth_strategy do
    if params[:user] == 'Frank' and params[:pass] == 'authlane'
      cookies[:'authlane.token'] = 'Frank'
      { id: 1 }
    end
  end

  Sinatra::AuthLane.create_remember_strategy do |token|
    { id: 1 } if token == 'Frank'
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
    'Frank has left the building'
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

  run!
end
