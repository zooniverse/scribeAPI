class ProjectsController < ApplicationController
  respond_to :json

  def index
  	respond_with Project.first
  end

end
