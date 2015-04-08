class GroupsController < ApplicationController
  respond_to :json

  def index
    respond_with Group.all
  end

  def show
    group = Group.find(params[:id])
    respond_with group
  end
end
