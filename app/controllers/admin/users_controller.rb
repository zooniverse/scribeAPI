class Admin::UsersController < Admin::AdminBaseController

  def show
    @user = User.find params[:id]
  end

  def index
    @users = User.all
  end
end
