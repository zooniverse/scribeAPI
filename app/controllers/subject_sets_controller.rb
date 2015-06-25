class SubjectSetsController < ApplicationController
  respond_to :json

  def index
    workflow_id  = params["workflow_id"]
    random = params["random"] || false
    limit  = params["limit"].to_i  || 10
    subject_request_scope = params["subject_request_scope"]
    
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

    # sets = sets.sort_by { |s| - s.subjects.first.secondary_subject_count }

    # Randomizer#random seems to want query criteria passed in under :selector key:
    respond_with sets, each_serializer: SubjectSetSerializer, workflow_id: workflow_id, limit: limit, random: random, subject_request_scope: subject_request_scope
  end

  # DOES NOT APPEAR TO BE IN USE -STI
  def show
    limit = 1 # should only return one (the matched set)
    # limit = params["limit"].to_i || 10
    puts 'SUBJECT SET ID: ', params[:subject_set_id]
    set = SubjectSet.where(id: params[:subject_set_id])
    workflow_id  = params["workflow_id"]

    return render status: 404, json: {status: 404} if set.nil?
    respond_with set, status: (set.nil? ? :not_found : 201), each_serializer: SubjectSetSerializer, workflow_id: workflow_id, limit: limit
  end

end
