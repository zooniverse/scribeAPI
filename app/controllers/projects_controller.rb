class ProjectsController < ApplicationController
  respond_to :json

  def index
    respond_with Project.current
  end

  def stats
    project = Project.first
    render :json => {:project => project, :stats => project.stats}
  end

  def project_css
    render text: Project.current.styles
  end

  def project_js
    render text: Project.current.custom_js
  end

end
