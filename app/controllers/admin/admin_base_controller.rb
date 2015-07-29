class Admin::AdminBaseController < ApplicationController
  layout "admin"

  before_action :check_admin_user, except: :signin

  def index
    redirect_to admin_dashboard_path
  end

  def check_admin_user
    if current_user.nil? || ! current_user.admin?
      puts "REDIR to admin signin: "
      redirect_to admin_signin_path
    end
  end
end
