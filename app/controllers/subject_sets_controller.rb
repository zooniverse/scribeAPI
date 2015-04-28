class SubjectSetsController < ApplicationController
  respond_to :json

  def index
    puts "SUBJECT SET CONTORLLER"
    puts "SUBJECT SET CONTORLLER"
    puts "SUBJECT SET CONTORLLER"
  	workflow_id  = params["workflow_id"]
    random = params["random"] || false
    limit  = params["limit"].to_i  || 10

    if  workflow_id
      query = {"counts.#{workflow_id}.active_subjects" => {"$gt"=>0}}
    else
      query = {}
    end

    if params["random"]
      sets = SubjectSet.random(selector: query, limit: limit)
    else
      sets = SubjectSet.where(query)
    end

    # Randomizer#random seems to want query criteria passed in under :selector key:
  	respond_with sets, each_serializer: SubjectSetSerializer, workflow_id: workflow_id, limit: limit, random: random
  end

  # DOES NOT APPEAR TO BE IN USE -STI
  # def show
  #   set = SubjectSet.find(params[:id])
  #   workflow_id  = params["workflow_id"]
  #
  #   respond_with set, serializer: SubjectSetSerializer, workflow_id: workflow_id
  # end

end
