class GroupsController < ApplicationController
  before_filter :parse_pagination, only: :index

  respond_to :json

  def index
    page          = get_int :page, 1
    limit         = get_int :limit, 25
    project_id    = get_objectid :project_id

    @groups = Group.all

    # If project_id given (it always should be), filter on it:
    if ! project_id.nil?
      @groups = @groups.by_project project_id
    end

    # Apply pagination:
    @groups = @groups.page(page).per(limit)

    # Build pagination links
    links = {
      "next" => {
        href: @groups.next_page.nil? ? nil : url_for(controller: 'groups', page: @groups.next_page),
      },
      "prev" => {
        href: @groups.prev_page.nil? ? nil : url_for(controller: 'groups', page: @groups.prev_page)
      }
    }

    respond_with GroupResultSerializer.new(@groups, scope: self.view_context), links: links
  end

  def show
    group = Group.find(params[:id])
    respond_with group
  end
end
