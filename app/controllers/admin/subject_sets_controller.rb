class Admin::SubjectSetsController < Admin::AdminBaseController

  def show
    @subject_set = SubjectSet.find params[:id]
  end

  def index
    @subject_sets = SubjectSet.all
  end
end
