class OmniauthCallbacksController < Devise::OmniauthCallbacksController

   def facebook
    @user = User.find_for_oauth(request.env["omniauth.auth"], current_user)

    if @user
      sign_in(@user, :bypass => true)
    end
    success_redirect
  end

  def zooniverse
   @user = User.find_for_oauth(request.env["omniauth.auth"], current_user)

   if @user
     sign_in(@user, :bypass => true)
   end
   success_redirect
  end

  def google_oauth2
    @user = User.find_for_oauth(request.env["omniauth.auth"], current_user)

    if @user
      sign_in(@user, :bypass => true)
    end
    success_redirect
  end

  private

  def success_redirect
    path = :root

    # Is there a URL to redirect to ?
    path = session.delete(:login_redirect) if session[:login_redirect]
    # Before redirecting them to an admin path, let's double check they're allowed
    path = :root if path.match(/^\/admin/) && ! @user.can_view_admin?

    redirect_to path
  end
end
