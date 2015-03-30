class WorkflowController < ApplicationController
  respond_to :json

  def index
  	respond_with  Workflow.all
  end

  def show
    workflow  = Workflow.find_by(name: params[:id]) || Workflow.find_by(id: params[:id])
    respond_with workflow
  end

end
