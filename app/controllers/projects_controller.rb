class ProjectsController < ApplicationController
  respond_to :json

  caches_action :index, :cache_path => "projects/index"

  def index
    respond_with Project.current
  end

  def stats
    project = Project.current
    render :json => {:project => project, :stats => project.stats}
  end


end
