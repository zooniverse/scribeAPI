class SubjectSetsController < ApplicationController
  respond_to :json

  def index
    workflow_id                 = get_objectid :workflow_id
    random                      = params["random"] || false
    subject_set_id              = get_objectid :subject_set_id

    subject_sets_limit          = get_int :limit, 10
    subject_sets_page           = get_int :page, 1

    subjects_limit              = get_int :subjects_limit, 100
    subjects_page               = get_int :subjects_page, 1

    # Filter out sets not apprpriate for workflow?
    if workflow_id
      query = {"counts.#{workflow_id}.active_subjects" => {"$gt"=>0}}
    else
      query = {}
    end

    # Get random set of subject-sets?
    if params["random"]
      # TODO: should randomizer really require a limit be passed? Currently seems required by selection method, but ideally shouldn't
      sets = SubjectSet.random(selector: query, limit: subject_sets_limit)

    # Selecting a specific subject_set?
    elsif ! subject_set_id.nil?
      sets = SubjectSet.where(id: subject_set_id)

    # Probably just selecting by workflow:
    else
      sets = SubjectSet.where(query)
    end

    # Apply pagination:
    sets = sets.page(subject_sets_page).per(subject_sets_limit)

    links = {
      "next" => {
        href: sets.next_page.nil? ? nil : url_for(controller: 'subject_sets', page: sets.next_page),
      },
      "prev" => {
        href: sets.prev_page.nil? ? nil : url_for(controller: 'subject_sets', page: sets.prev_page)
      }
    }

    respond_with SubjectSetResultSerializer.new(sets), workflow_id: workflow_id, subjects_limit: subjects_limit, subjects_page: subjects_page, links: links
  end

  def show
    # puts 'PARAMS: ', params
    # limit = 1 # should only return one (the matched set)
    subject_id = params[:subject_id]
    page = params[:page].to_i
    limit = params["limit"].to_i || 10
    # puts 'SUBJECT SET ID: ', params[:subject_set_id]
    set = SubjectSet.where(id: params[:subject_set_id])
    workflow_id  = params["workflow_id"]

    return render status: 404, json: {status: 404} if set.nil?
    respond_with set, status: (set.nil? ? :not_found : 201), each_serializer: SubjectSetSerializer, workflow_id: workflow_id, subject_id: subject_id, limit: limit, page: page
  end

  def name_search
    @names = SubjectSet.autocomplete_name(params[:annotation_key])
    respond_with @names
  end

end
