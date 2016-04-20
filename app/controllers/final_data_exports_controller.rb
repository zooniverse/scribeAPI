class FinalDataExportsController < FinalDataController 

  def latest
    puts "FinalDataExport.most_recent.first: #{FinalDataExport.most_recent.first.inspect}"
    show FinalDataExport.most_recent.first
  end

  def show(export = nil)
    export = FinalDataExport.find(params[:id]) unless export
    return render text: 'Not found.', status: 404 if export.nil?

    redirect_to export.path
  end

  def index
    @exports = FinalDataExport.most_recent.limit(20)

    respond_to do |format|
      format.atom
    end
  end

end
