class Admin::SubjectsController < Admin::AdminBaseController

  def show
    @subject = Subject.find params[:id]
  end

  def index
    @subjects = Subject.where(type: "root")
  end
end
