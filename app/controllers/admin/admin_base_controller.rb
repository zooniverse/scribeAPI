class Admin::AdminBaseController < ApplicationController
  layout "admin"

  def index
    redirect_to admin_dashboard_path
  end
end
