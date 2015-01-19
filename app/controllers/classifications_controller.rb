class ClassificationsController < ApplicationController
  respond_to :json

  def create
    annotations = params["annotations"]
    subject_id  = BSON::ObjectId.from_string params["subject_id"]
    workflow_id = params["workflow_id"]
    
    # workflow_id = BSON::ObjectId.from_string params["workflow_id"]
    # user_id     = BSON::ObjectId.from_string params["user_id"]
    
    # TODO: still need to add user_id
    @result     = Classification.create( workflow_id: workflow_id, subject_id: subject_id, annotations: annotations )
    # @result     = Classification.create( annotations: annotations )
    
    respond_with @result
  end
end