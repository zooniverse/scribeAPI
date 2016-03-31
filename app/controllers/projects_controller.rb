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

=begin
  def project_css
    render text: Project.current.styles
  end

  def project_js
    render text: Project.current.custom_js
  end
=end

end
