class DashboardController < ApplicationController
  
  layout "dashboard"

  def index
    
  end

  def ancestory
    @root_subjects = Subject.where(type: "root")
  end



end
