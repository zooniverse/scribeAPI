class ClassificationsController < ApplicationController
  respond_to :json

  def create

    workflow_id      = BSON::ObjectId.from_string params["classifications"]["workflow_id"]
    generates_subject_type = params["classifications"]["annotation"]["generates_subject_type"]
    
    tool_box         = find_tool_box(workflow_id, generates_subject_type)
    tool_name        = tool_box["type"]
    label            = tool_box["label"]
    
    annotation       = params["classifications"]["annotation"]
    started_at       = params["classifications"]["metadata"]["started_at"]
    finished_at      = params["classifications"]["metadata"]["finished_at"]
    user_agent       = request.headers["HTTP_USER_AGENT"]
    
    #user_id     = BSON::ObjectId.from_string params["user_id"]
    #use subject_id params
    #TODO session id


    # TODO PB: subject_id should be submitted as part of the classification, not embedded within the annotation like this:
    subject_id = annotation["subject_id"]


    @result = Classification.create(
      workflow_id: workflow_id,
      subject_id: subject_id,
      tool_name: tool_name,
      label: label,
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

  private

  def find_tool_box(workflow_id, generates_subject_type)
    workflow = Workflow.find(workflow_id)
    tool_box = workflow.find_tools_from_subject_type(generates_subject_type)
    # example tool_box: {"type"=> "textRowTool", "label"=> "Question", "color"=> "green", "generates_subject_type"=> "att_textRowTool_question" }
  end

end
