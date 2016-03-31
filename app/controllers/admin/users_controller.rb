class Admin::UsersController < Admin::AdminBaseController

  def show
    @user = User.find params[:id]
  end

  def index
    page        = get_int :page, 1
    limit       = get_int :limit, 20

    @users = User.page(page).per(limit)
  end
end
