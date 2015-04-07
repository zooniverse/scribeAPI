class SubjectsController < ApplicationController
  respond_to :json

  def index
  	workflow_id  = params["workflow_id"]
    # Randomizer#random seems to want query criteria passed in under :selector key:
  	respond_with  Subject.random(:selector => {:workflow_ids => BSON::ObjectId.from_string(workflow_id)}, limit: (params[:limit].to_i || 5) )
  end

end
