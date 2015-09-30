class SubjectSetsController < ApplicationController
  respond_to :json

  def index
    workflow_id                 = get_objectid :workflow_id
    group_id                    = get_objectid :group_id
    random                      = get_bool :random, false
    subject_set_id              = get_objectid :subject_set_id

    subject_sets_limit          = get_int :limit, 1
    subject_sets_page           = get_int :page, 1

    subjects_limit              = get_int :subjects_limit, 100
    subjects_page               = get_int :subjects_page, 1

    query = {}
    
    # Filter out sets not apprpriate for workflow?
    query["counts.#{workflow_id}.active_subjects"] = {"$gt"=>0} if ! workflow_id.nil?

    # Filter by group_id? 
    query[:group_id] = group_id if ! group_id.nil? 

    # Override random if querying by subject_set_id:
    random = false if ! subject_set_id.nil?

    # Get random set of subject-sets?
    if random
      # TODO: should randomizer really require a limit be passed? Currently seems required by selection method, but ideally shouldn't
      @subject_sets = SubjectSet.random(selector: query, limit: subject_sets_limit)

    # Selecting a specific subject_set?
    elsif ! subject_set_id.nil?
      @subject_sets = SubjectSet.where(id: subject_set_id)

    # Probably just selecting by workflow:
    else
      @subject_sets = SubjectSet.where(query)
    end

    # Apply pagination:
    @subject_sets = @subject_sets.page(subject_sets_page).per(subject_sets_limit)

    links = {
      "next" => {
        href: @subject_sets.next_page.nil? ? nil : url_for(controller: 'subject_sets', page: @subject_sets.next_page),
      },
      "prev" => {
        href: @subject_sets.prev_page.nil? ? nil : url_for(controller: 'subject_sets', page: @subject_sets.prev_page)
      }
    }

    respond_with SubjectSetResultSerializer.new(@subject_sets, scope: self.view_context), workflow_id: workflow_id, subjects_limit: subjects_limit, subjects_page: subjects_page, links: links
  end

  def show
    subject_set_id              = get_objectid :subject_set_id
    subjects_limit              = get_int :subjects_limit, 100
    subjects_page               = get_int :subjects_page, 1

    @subject_set = SubjectSet.find subject_set_id

    return render status: 404, json: {status: 404} if @subject_set.nil?

    links = {self: url_for(@subject_set)}

    respond_with SubjectSetResultSerializer.new(@subject_set, scope: self.view_context), subjects_limit: subjects_limit, subjects_page: subjects_page, links: links
  end

  def name_search
    @names = SubjectSet.autocomplete_name(params[:field], params[:q])
    respond_with @names
  end

end
