class ProjectsController < ApplicationController
  respond_to :json

  def index
  	respond_with Project.first
  end
  
  def stats
    project = Project.first
    render :json => {:project => project, :stats => project.stats}
  end

end
