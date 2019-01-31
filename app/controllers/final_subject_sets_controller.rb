class FinalSubjectSetsController < FinalDataController 
  respond_to :json

  def show
    @set = FinalSubjectSet.find params[:id]
    respond_with FinalSubjectSetSerializer.new @set
  end

  def index
    per_page              = get_int :per_page, 20, (0..50)
    page                  = get_int :page, 1

    keyword               = params[:keyword]

    @sets = FinalSubjectSet.page(page).per(per_page)
    @sets = @sets.where({"$text" => {"$search" => keyword} } ) if keyword

    respond_with GenericResultSerializer.new(@sets)
  end

end
