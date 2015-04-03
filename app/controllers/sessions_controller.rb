class SessionsController < ApplicationController
  respond_to :json, :html

  def new
  end

  def create
    user = User.from_omniauth(env["omniauth.auth"])

    session[:user_id] = user.id
    respond_to do |format|
      format.json{render json: current_user}
      format.html{redirect_to root_url, :notice => "Signed in!"}
    end
  end

  def destroy
    session[:user_id] = nil
    sign_out(current_user)

    respond_to do |format|
      format.json {render json: {notice: "Signed out!"}, status: 200}
      format.html {redirect_to root_url, :notice => "Signed out!"}
    end
  end

protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
