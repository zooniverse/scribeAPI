class SubjectsController < ApplicationController
  respond_to :json

  def index
  	workflow_id  = params["workflow_id"]
    random = params["random"] || false
    limit  = params["limit"].to_i  || 10

    query = {}

    if params["random"]
      sets = Subject.random(selector: query, limit: limit)
    else
      sets = Subject.where(query)
    end

    respond_with sets, each_serializer: SubjectSerializer, workflow_id: workflow_id

  end

end
