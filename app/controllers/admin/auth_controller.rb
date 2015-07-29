class Admin::AuthController < Admin::AdminBaseController

  def signin 
    @providers = User.auth_providers
  end

end
