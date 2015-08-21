class UsersController < ApplicationController
  respond_to :json

  def logged_in_user
    providers = User.auth_providers
    
    respond_with AuthStateSerializer.new(user: current_or_guest_user, providers: providers)
  end

  def tutorial_complete
    if current_or_guest_user != nil
      current_or_guest_user.update_attributes(tutorial_complete: true)
      respond_with current_or_guest_user.tutorial_complete
    else
      respond_with false
    end
  end

end
