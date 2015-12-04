class HomeController < ApplicationController
  caches_action :index, :cache_path => "home/index"
  
  def index
  end
end
