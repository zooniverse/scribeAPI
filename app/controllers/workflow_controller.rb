class WorkflowController < ApplicationController
  respond_to :json 

  def index
  	key  = params["key"]
    respond_with  Workflow.find_by(:key => key )
  end

end