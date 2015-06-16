class Admin::ClassificationsController < Admin::AdminBaseController

  def show
    @classification = Classification.find params[:id]
  end

  def index
    @classification = Classification.all
  end
end
