class GroupsController < ApplicationController
  before_filter :parse_pagination, only: :index

  respond_to :json

  def index
    @groups = Group.all
    # If project_id given (it always should be), filter on it:
    if ! (project_id = get_objectid(:project_id)).nil?
      @groups = @groups.by_project project_id
    end
    @groups.paginate(page: @page, per_page: @per_page)
    respond_with @groups
  end

  def show
    group = Group.find(params[:id])
    respond_with group
  end
end
