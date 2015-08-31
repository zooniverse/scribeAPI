class UsersController < ApplicationController
  respond_to :json

  def logged_in_user
    providers = User.auth_providers
    
    respond_with AuthStateSerializer.new(user: current_or_guest_user, providers: providers)
  end

  def tutorial_complete
    user = require_user!
    user.tutorial_complete!
    respond_with user.tutorial_complete
  end

end
