require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/authlane'

# Usually, a `forget` strategy is needed as well in order to
# handle the server side logic for forgetting user logins.
# For example, your `auth` strategy might add the token to
# a database table with the user id, so the `remember` strategy
# can reference that information.
# The `forget` strategy would be responsible for removing the
# entry from the database.
#

# Our 'database'
$db = File.join(File.dirname(__FILE__), 'token')

class App < Sinatra::Base
  register Sinatra::AuthLane
  helpers Sinatra::Cookies

  set :sessions, true

  Sinatra::AuthLane.create_auth_strategy do
    if params[:user] == 'Frank' and params[:pass] == 'authlane'
      token = rand(10).to_s

      File.open($db, 'w+') do |f|
        f.write token
      end

      cookies[:'authlane.token'] = token
      { id: 1 }
    end
  end

  Sinatra::AuthLane.create_remember_strategy do |token|
    read_token = ''

    File.open($db, 'r') do |f|
      read_token = f.read
    end

    { id: 1 } if token == read_token
  end

  Sinatra::AuthLane.create_forget_strategy do |token|
    File.open($db, 'w+') do |f|
      f.write ''
    end
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
