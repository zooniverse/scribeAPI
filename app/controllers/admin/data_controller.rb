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

      elsif params[:download_status] == 'flat'
        @subjects = Subject.all.skip(100).limit(1).first.child_subjects.where(workflow_id: nil)
        respond_to do |format|
          format.json {render json: @subjects.map { |s| FinalDataSubjectSerializer.new(s, root: false) }}
        end

      else
        @sets = SubjectSet.all.skip(101).limit 1
        respond_to do |format|
          format.json {render json: FinalDataSerializer.new(@sets)}
        end
      end
    end
  end
end
