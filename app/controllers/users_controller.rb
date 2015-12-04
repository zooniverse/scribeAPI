class UsersController < ApplicationController
  respond_to :json

  def logged_in_user
    providers = User.auth_providers

    respond_with AuthStateSerializer.new(user: current_or_guest_user, providers: providers)
  end

  def tutorial_complete

    user = require_user!
    user.tutorial_complete!

    render json: AuthStateSerializer.new(user: current_or_guest_user, providers: User.auth_providers), status: 200
  end

  def set_subject_bookmark
    puts 'users_controller#set_subject_bookmark'
  end

end
