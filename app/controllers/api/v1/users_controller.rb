class Api::V1::UsersController < ApplicationController
  before_action :authenticate_request, except: [:index, :create, :login, :facebook_token]

  def index
    @users = User.all
    render json: { msg: 'Nothing to see here.' }, status: :ok
  end

  # curl -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE0OTU0ODc2OTMsImlzcyI6IkNvbnRhY3QgS2VlcGVyIiwiYXVkIjoiY2xpZW50In0.En5teUqtn2wIOkYPuvnxK1QgkrwRG7Tkj1NGRSvDX-k" http://localhost:3000/api/v1/users/1
  def show
    @user = User.find(params[:id])
      render json: {
        username: @user.username,
        first_name: @user.first_name,
        last_name: @user.last_name,
        email: @user.email,
        phone_number: @user.phone_number,
        contacts: @user.contacts
      }, status: :ok
  end

  # curl -X POST -H "Content-Type: application/json" -d '{ "user": { "username": "jfriedman", "first_name": "Jeff", "last_name": "Friedman", "email": "test@test.com", "phone_number": "617-123-4567", "password": "password", "password_confirmation": "password" }}' http://localhost:3000/api/v1/users
  def create
    params[:email] = params[:email].to_s.downcase
    @user = User.new(user_params)
    if @user.save
      auth_token = JsonWebToken.encode({ user_id: @user.id })
      @user.update(valid_jwt: true)
      render json: {
        username: @user.username,
        first_name: @user.first_name,
        last_name: @user.last_name,
        email: @user.email,
        phone_number: @user.phone_number,
        auth_token: auth_token
      }, status: :ok
    else
      render json: { error: @user.errors.full_messages.join(', ') }, status: :bad_request
    end
  end

  # curl -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE0OTU0ODc2OTMsImlzcyI6IkNvbnRhY3QgS2VlcGVyIiwiYXVkIjoiY2xpZW50In0.En5teUqtn2wIOkYPuvnxK1QgkrwRG7Tkj1NGRSvDX-k" -d '{ "user": { "phone_number": "617-111-2222" }}' http://localhost:3000/api/v1/users/1
  def update
    @user = User.find(params[:id])
    params[:email] = params[:email].to_s.downcase
    @user.assign_attributes(user_params)
    if @user.save
      render json: {
        message: "Update successful."
      }, status: :ok
    else
      render json: { error: @user.errors.full_messages.join(', ') }, status: :bad_request
    end
  end

  # curl -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE0OTU0ODc2OTMsImlzcyI6IkNvbnRhY3QgS2VlcGVyIiwiYXVkIjoiY2xpZW50In0.En5teUqtn2wIOkYPuvnxK1QgkrwRG7Tkj1NGRSvDX-k" http://localhost:3000/api/v1/users/1
  def destroy
    @user = User.find(params[:id])
    @user.destroy
  end

  # curl -X POST -H "Content-Type: application/json" -d '{ "email": "test@test.com", "password": "password" }' http://localhost:3000/api/v1/users/login
  def login
    @user = User.find_by(email: params[:email].to_s.downcase)

    # authenticate method provided by has_secure_password
    if @user&.authenticate(params[:password])
        @current_user = @user
        auth_token = JsonWebToken.encode({ user_id: @user.id })
        @current_user.update(valid_jwt: true)
        render json: { auth_token: auth_token }, status: :ok
    else
      render json: { error: 'Invalid username / password' }, status: :unauthorized
    end
  end
  
  def confirm_login
    if (current_user)
      render json: {
        id: current_user.id,
        username: current_user.username,
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        email: current_user.email,
        phone_number: current_user.phone_number,
        contacts: current_user.contacts
      }, status: :ok
    else
      render json: {
        msg: 'Not authenticated.'
      }, status: :forbidden
    end
  end
  
  # curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE0OTg3ODIyMDIsImlzcyI6IkNvbnRhY3QgS2VlcGVyIiwiYXVkIjoiY2xpZW50In0.z7HSguRBmX59Lyvr57gZHA8iy0WN_4EIP2XWYXmsKRY" http://localhost:8080/api/v1/users/logout
  def logout
    current_user.update(valid_jwt: false)
  end

  def facebook_token
    user_info, access_token = FacebookToken.authenticate(params['facebookInfo']['accessToken'])
    render json: {
      status: 'Successfully authenticated with Facebook.',
      photo: user_info['picture']['data']['url']
    }, status: :ok
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :username, :email, :phone_number, :password, :password_confirmation)
  end
end
