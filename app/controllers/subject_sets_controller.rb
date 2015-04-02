class SubjectSetsController < ApplicationController
  respond_to :json

  def index
  	workflow_id  = params["workflow_id"]
    puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    puts workflow_id
    
    # Randomizer#random seems to want query criteria passed in under :selector key:
    sets = SubjectSet.random(:selector => {:workflow_ids => BSON::ObjectId.from_string(workflow_id)}, limit: (params[:limit].to_i || 5) )
    sets.select! { |s| s.subjects.size > 1 }
  	respond_with sets
  end

end
