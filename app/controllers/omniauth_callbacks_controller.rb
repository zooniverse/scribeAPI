class OmniauthCallbacksController < Devise::OmniauthCallbacksController

   def facebook
    # You need to implement the method below in your model
    @user = User.find_for_oauth(request.env["omniauth.auth"], current_user)

    if @user
      sign_in(@user, :bypass => true)
    end
    redirect_to :root
  end

  def zooniverse
   # You need to implement the method below in your model
   @user = User.find_for_oauth(request.env["omniauth.auth"], current_user)

   if @user
     sign_in(@user, :bypass => true)
   end
   redirect_to :root
 end

end
