class ClassificationsController < ApplicationController
  include ActionView::Helpers::TextHelper
  respond_to :json

  def create

    # Is it a bot?
    user = nil
    if request.headers["HTTP_ROBOT_AUTH"]
      user = User.bot_user_by_auth request.headers["HTTP_ROBOT_AUTH"]
    end

    user = require_user! if user.nil?

    workflow_id      = params["classifications"]["workflow_id"] ? params["classifications"]["workflow_id"] : nil
    task_key         = params["classifications"]["task_key"]

    annotation       = params["classifications"]["annotation"]
    annotation       = {} if annotation.nil?

    started_at       = nil
    finished_at      = nil
    if params["classifications"]["metadata"]
      started_at = params["classifications"]["metadata"]["started_at"]
      finished_at      = params["classifications"]["metadata"]["finished_at"]

    else
      started_at = finished_at       = Time.new.strftime("%Y%m%dT%H%M%S%z")
    end

    subject_id       = params["classifications"]["subject_id"]
    user_agent       = request.headers["HTTP_USER_AGENT"]

    if workflow_id.nil? && ! params["workflow"].nil?
      workflow = Workflow.find_by name: params["workflow"]["name"]
      workflow_id = workflow.id
    end

    workflow_id = BSON::ObjectId.from_string workflow_id if ! workflow_id.nil?

    if subject_id.nil? && (standard_url = params["subject"]["location"]["standard"])
      subject_id = Subject.find_or_create_root_by_standard_url(standard_url).id
    end

    h = {
      annotation: annotation,
      location: location,
      subject_id: subject_id,
      task_key: task_key,
      workflow_id: workflow_id,
      user_id: user.id
    }
    if (@result = Classification.find_by_props(h)).nil?
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
    end
    render json: @result
  end


  def terms
    workflow_id = params[:workflow_id]
    annotation_key = params[:annotation_key]
    q = params[:q]

    terms = Term.autocomplete workflow_id, annotation_key, q
    respond_with terms
  end


end
