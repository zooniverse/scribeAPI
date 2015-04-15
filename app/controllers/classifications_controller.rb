class ClassificationsController < ApplicationController
  respond_to :json

  def show
    puts 'SHOW: ', params["subject_id"]
    subject_id  = params["subject_id"]
    respond_with  Classification.find_by( _id: params[:subject_id] )
  end

  def create
    binding.pry
    annotations = params["annotations"]
    subject_set_id  = BSON::ObjectId.from_string params["classifications"]["subject_set"]["id"]
    workflow_id = BSON::ObjectId.from_string params["workflow_id"]

    location         = params["location"]
    annotations      = params["annotations"]
    started_at       = params["started_at"]
    finished_at      = params["finished_at"]
    user_agent       = params["user_agent"]
    # user_id     = BSON::ObjectId.from_string params["user_id"]

    # TODO: still need to add user_id

    @result = Classification.create( workflow_id: workflow_id, subject_id: subject_id, location: location, annotations: annotations, started_at: started_at, finished_at: finished_at, user_agent: user_agent )
    respond_with @result
  end
end
