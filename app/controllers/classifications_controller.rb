require 'pry'
class ClassificationsController < ApplicationController
  include ActionView::Helpers::TextHelper
  respond_to :json

  def create
    user = require_user!

    workflow_id      = BSON::ObjectId.from_string params["classifications"]["workflow_id"]
    task_key         = params["classifications"]["task_key"]

    annotation       = params["classifications"]["annotation"]
    # if annotation.keys().include?("value")
    #   annotation["value"] = invalid_line_ending_check(annotation["value"])
    # end
    
    annotation       = {} if annotation.nil?
    started_at       = params["classifications"]["metadata"]["started_at"]
    finished_at      = params["classifications"]["metadata"]["finished_at"]
    subject_id       = params["classifications"]["subject_id"]
    user_agent       = request.headers["HTTP_USER_AGENT"]

    @result = Classification.create(
      workflow_id: workflow_id,
      subject_id: subject_id,
      location: location,
      annotation: annotation,
      started_at: started_at,
      finished_at: finished_at,
      user_agent: user_agent,
      task_key: task_key,
      user: user
    )

    respond_with @result
  end

  # def invalid_line_ending_check(string)
  #   string.gsub(/(?:\n\r?|\r\n?)/, '<br>')
  # end


  def terms
    workflow_id = params[:workflow_id]
    annotation_key = params[:annotation_key]
    q = params[:q]

    terms = Term.autocomplete workflow_id, annotation_key, q
    respond_with terms
  end


end
