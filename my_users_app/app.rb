require 'sinatra'
require 'json'
require 'erb'
require_relative 'my_user_model'

# --- Configuration ---
# Set server binding and port
set :bind, '0.0.0.0'
set :port, 8080

# Enable sessions for user login
enable :sessions

configure do
    User.init_db
end

# Set view directory
set :views, File.dirname(__FILE__) + '/views'

# --- Helper Methods ---
# Helper to strip password from a user hash
def user_without_password(user)
    hash = user.to_h
    hash.delete('password')
    hash.delete(:password)
    hash
end

# Helper to get body params (handles form-encoded and JSON)
def body_params
    request.body.rewind
    body = request.body.read
  
    if body.empty?
        {}
    elsif request.content_type&.include?('application/json')
        JSON.parse(body)
    else
        # Parse form-encoded data manually
        URI.decode_www_form(body).to_h
    end
    rescue => e
        puts "Error parsing body: #{e.message}"
        {}
end

# GET /users - Return all users
get '/users' do
    content_type :text
    users = User.all.map { |user| user_without_password(user) }
    users.to_json
end

# POST /users - Create a new user
post '/users' do
    content_type :text
    user_params = body_params
    new_user = User.create(user_params)
    user_without_password(new_user).to_json
end

# POST /sign_in - Log a user in
post '/sign_in' do
    content_type :text
    user_params = body_params
    user = User.authenticate(user_params['email'], user_params['password'])
  
    if user
        session[:user_id] = user.id
        user_without_password(user).to_json
    else
        status 401 # Unauthorized
        { error: 'Invalid email or password' }.to_json
    end
end

# PUT /users - Update current user's password
put '/users' do
    content_type :text

    # Require login
    unless session[:user_id]
        status 401 # Unauthorized
        return { error: 'You must be logged in' }.to_json
    end

    user_params = body_params
  
    # Check for new password
    unless user_params['password']
        status 400 # Bad Request
        return { error: 'New password is required' }.to_json
    end
  
    user_id = session[:user_id]
    user = User.update(user_id, 'password', user_params['password'])
    user_without_password(user).to_json
end

# DELETE /sign_out - Log the current user out
delete '/sign_out' do
    # Require login
    unless session[:user_id]
        status 401 # Unauthorized
        return
    end
    
    session.clear
    status 204 # No Content
end

# DELETE /users - Delete the current user's account
delete '/users' do
    # Require login
    unless session[:user_id]
        status 401 # Unauthorized
        return { error: 'You must be logged in' }.to_json
    end
    
    user_id = session[:user_id]
    session.clear
    User.destroy(user_id)

    status 204 # No Content
end

# --- HTML View Route (Part III) ---

# GET / - Render the HTML index page
get '/' do
    # This route responds with HTML
    @users = User.all
    erb :index
end