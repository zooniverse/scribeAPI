class Admin::DataController < Admin::AdminBaseController

  def index
    @num_complete = Subject.complete.count
    @num_non_root = Subject.active_non_root.count
  end 
  
  def download
    if params[:download_format]
      redirect_to "#{admin_data_download_path}.#{params[:download_format]}?download_status=#{params[:download_status]}"

    else

      if params[:download_status] == 'complete'
        @subjects = Subject.complete
        respond_to do |format|
          format.json {render json: CompleteSubjectsSerializer.new(@subjects)}
        end

      else
        @sets = SubjectSet.all
        respond_to do |format|
          format.json {render json: FinalDataSerializer.new(@sets)}
        end
      end
    end
  end
end
