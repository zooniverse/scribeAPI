class SubjectsController < ApplicationController
  respond_to :json

  def index
  	workflow_id  = params["workflow_id"]
    # Randomizer#random seems to want query criteria passed in under :selector key:
  	respond_with  Subject.where(workflow_id: workflow_id)
  end

end
