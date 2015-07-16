class UsersController < ApplicationController
  respond_to :json

  def logged_in_user
    respond_with current_or_guest_user
  end

end
