class Admin::SubjectSetsController < Admin::AdminBaseController

  def show
    @subject_set = SubjectSet.find params[:id]
  end

  def index
    page        = get_int :page, 1
    limit       = get_int :limit, 20

    @subject_sets = SubjectSet.page(page).per(limit)
  end
end
