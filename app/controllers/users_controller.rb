class UsersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json 


  def index
    @users = User.all
    respond_with @users
  end

  def show
    @user = User.find(params[:id])
    respond_with @user
  end

  def current_user 
    binding.pry
    respond_with current_user
  end

end
