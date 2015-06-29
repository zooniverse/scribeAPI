class SubjectsController < ApplicationController
  respond_to :json

  def index
    puts "INDEX SUBJECTS CONTROLLER"
    puts params
    workflow_id  = params["workflow_id"]
    parent_subject_id = params["parent_subject_id"]
    random = params["random"] || false
    limit = params["limit"].to_i || 10

    # TO DO: REFACTOR THIS UGLY CODE. -STI
    if parent_subject_id
      respond_with Subject.active.where(workflow_id: workflow_id, parent_subject_id: parent_subject_id)
    else
      # Randomizer#random seems to want query criteria passed in under :selector key:
    	if random
        respond_with Subject.active.where(workflow_id: workflow_id).random(limit: limit)
      else
        respond_with Subject.active.where(workflow_id: workflow_id).limit(limit)
      end
    end
  end

  def show
    subject_id  = params["subject_id"]
    @subject = Subject.find_by( _id: params[:subject_id] )
    respond_with  @subject
  end



end
