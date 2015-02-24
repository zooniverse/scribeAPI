class SubjectsController < ApplicationController
  respond_to :json

  def index
  	workflow_id  = params["workflow_id"]
    puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    puts workflow_id
    
  	respond_with  Subject.random(:workflow_ids => BSON::ObjectId.from_string(workflow_id), limit: (params[:limit].to_i || 5) )
  end

end
