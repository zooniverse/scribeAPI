class UsersController < ApplicationController
  respond_to :json

  def logged_in_user
    respond_with current_user
  end

end
