class ProjectsController < ApplicationController
  respond_to :json

  def index
    puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    @project = Project.first
  	respond_with Project.first

  end

end
