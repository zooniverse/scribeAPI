class ProjectsController < ApplicationController
  respond_to :json

  def index
  	# respond_with Project.first

    # Get most recently updated, in lieu of some other project selection mechanism:
    respond_with Project.order(updated_at: -1).first

  end

end
