class Admin::DataController < Admin::AdminBaseController

  def index
    @project = Project.current
    if request.post?
      if (proj = params[:project])
        if (v = proj[:downloadable_data])
          new_val  = v == '1'
          puts "updating project: #{new_val} because #{v}"
          @project.update_attributes downloadable_data: new_val
        end
      end
    end
    @export = FinalDataExport.most_recent.first
  end 
end
