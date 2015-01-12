class ClassificationsController < ApplicationController
  respond_to :json

  def new
  end

  def create
  	annotations = params["annotations"]
  	subject_id  = BSON::ObjectId.from_string params["subject_id"]
  	workflow_id = BSON::ObjectId.from_string params["workflow_id"]
  	user_id     = BSON::ObjectId.from_string params["user_id"]
  	@result     = Classification.create(workflow_id: workflow_id, subject_id: subject_id, user_id: user_id)
    respond_with @result
  end
end
