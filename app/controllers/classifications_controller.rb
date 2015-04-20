class ClassificationsController < ApplicationController
  respond_to :json

  def show
    puts 'SHOW: ', params["subject_id"]
    subject_id  = params["subject_id"]
    respond_with  Classification.find_by( _id: params[:subject_id] )
  end

  def create
    puts params
    puts session
    binding.pry
    annotations = params["annotations"]
    subject_set_id  = BSON::ObjectId.from_string params["classifications"]["subject_set"]["id"]
    workflow_id = BSON::ObjectId.from_string params["classifications"]["workflow_id"]

    # location         = params["location"] 
    annotations      = params["classifications"]["annotations"]
    started_at       = params["classifications"]["metadata"]["started_at"]
    finished_at      = params["classifications"]["metadata"]["finished_at"]
    user_agent       = request.headers["HTTP_USER_AGENT"]
    #user_id     = BSON::ObjectId.from_string params["user_id"]
    subject_id = session.id #this should change
    annotations.each do |annotation|
      # for each flagged annoation, we want to create subject

      # sample annotation 
      # {"value"=>
      #   [{
      #    "key"=>0, "tool"=>1, "x"=>511.8947037631256, "y"=>353.5964912280702, "width"=>414.5613766314635, "height"=>243.85964912280696, "status"=>"mark"}],
      #    "task"=>"identify_records",
      #    "subject_id"=>"5527d5bb412d4d46f5030000",
      #    "workflow_id"=>"5527d5bb412d4d46f5000000"
      #   }]
      subject_id = annotation["subject_id"]
      annotation
    end 
    
    # TODO, still need to: 
    # add user_id
    # started_at: started_at, finished_at: finished_at, user_agent: user_agent

    @result = Classification.create( 
      workflow_id: workflow_id, 
      subject_id: subject_id, 
      location: location, 
      annotations: annotations, 
      started_at: started_at, 
      finished_at: finished_at, 
      user_agent: user_agent )
    respond_with @result
  end
end
