class ProjectsController < ApplicationController
  respond_to :json

  def index
    respond_with Project.current
  end

end
