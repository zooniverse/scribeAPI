class SubjectsController < ApplicationController
  respond_to :json

  def index
  	workflow_id  = params["workflow_id"]
    random = params["random"] || false
    limit = params["limit"].to_i || 10

    # Randomizer#random seems to want query criteria passed in under :selector key:
  	if random
      respond_with Subject.random(limit: limit)
    else
      respond_with  Subject.limit(limit)
    end
  end

end
