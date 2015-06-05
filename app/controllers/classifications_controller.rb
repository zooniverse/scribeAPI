require 'pry'
class ClassificationsController < ApplicationController
  respond_to :json
  # EARLY CODE TO FAKE SECONDARY SUBJECTS -STI
  # def show
  #   puts 'SHOW: ', params["subject_id"]
  #   subject_id  = params["subject_id"]
  #   respond_with  Classification.find_by( _id: params[:subject_id] )
  # end


  def create
    binding.pry
    workflow_id      = BSON::ObjectId.from_string params["classifications"]["workflow_id"]
    task_key         = params["classifications"]["task_key"]
    generates_subject_type = params["classifications"]["annotation"]["generates_subject_type"]

    if generates_subject_type
      tool_box         = find_tool_box(workflow_id, generates_subject_type)
      tool_name        = tool_box["type"]
      label            = tool_box["label"]
    end
    
    annotation       = params["classifications"]["annotation"]
    started_at       = params["classifications"]["metadata"]["started_at"]
    finished_at      = params["classifications"]["metadata"]["finished_at"]
    subject_id       = params["classifications"]["subject_id"]
    user_agent       = request.headers["HTTP_USER_AGENT"]
    # hack incoming annotation hash to match dm doc:
    # annotation = annotation['value'] && annotation['value']['0'] ? annotation['value']['0'] : annotation

    # annotation['generates_subject_type'] = params['classifications']['generates_subject_type']


    @result = Classification.create(
      workflow_id: workflow_id,
      subject_id: subject_id,
      location: location,
      annotation: annotation,
      started_at: started_at,
      finished_at: finished_at,
      user_agent: user_agent,
      task_key: task_key,
      tool_name: tool_name ? tool_name : nil,
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
