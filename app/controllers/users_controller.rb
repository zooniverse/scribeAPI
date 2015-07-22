class UsersController < ApplicationController
  respond_to :json

  def logged_in_user
    providers = API::Application.config.auth_providers
    respond_with AuthStateSerializer.new(user: current_or_guest_user, providers: providers)
  end

end
