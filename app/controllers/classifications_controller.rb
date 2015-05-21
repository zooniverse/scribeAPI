class ClassificationsController < ApplicationController
  respond_to :json

  def create
    annotations      = params["annotations"]
    workflow_id      = BSON::ObjectId.from_string params["classifications"]["workflow_id"]
    annotation       = params["classifications"]["annotation"]
    tool_name        = params["classifications"]["annotation"]["tool_task_description"]["type"]
    started_at       = params["classifications"]["metadata"]["started_at"]
    finished_at      = params["classifications"]["metadata"]["finished_at"]
    user_agent       = request.headers["HTTP_USER_AGENT"]
    #user_id     = BSON::ObjectId.from_string params["user_id"]
    #use subject_id params
    
    # PB: Setting subject_id to session.id? Is this a mistake? Commenting it out:
    # subject_id = session.id #this should change, auth currently not working
    subject_id = nil

    # TODO PB: subject_id should be submitted as part of the classification, not embedded within the annotation like this:
    subject_id = annotation["subject_id"]


    @result = Classification.create(
      workflow_id: workflow_id,
      subject_id: subject_id,
      tool_name: tool_name,
      annotation: annotation,
      started_at: started_at,
      finished_at: finished_at,
      user_agent: user_agent 
      )

    respond_with @result
 
  end

  def terms
    workflow_id = params[:workflow_id]
    annotation_key = params[:annotation_key]
    q = params[:q]

    terms = Term.autocomplete workflow_id, annotation_key, q
    respond_with terms
  end
end
