class Admin::DataController < Admin::AdminBaseController

  def index
  end 
  
  def download
    if params[:download_format]
      redirect_to "#{admin_data_download_path}.#{params[:download_format]}"

    else

      @subjects = Subject.complete

      respond_to do |format|
        format.json {render json: CompleteSubjectsSerializer.new(@subjects)}
      end
    end
  end
end
