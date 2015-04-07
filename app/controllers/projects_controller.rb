class ProjectsController < ApplicationController
  respond_to :json

  def index
    respond_with Project.current
  end

  def project_css
    render text: Project.current.styles
  end
end
