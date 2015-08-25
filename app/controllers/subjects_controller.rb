class SubjectsController < ApplicationController
  respond_to :json

  def index
    user = current_or_guest_user


    workflow_id           = get_objectid :workflow_id
    parent_subject_id     = get_objectid :parent_subject_id
    random                = get_bool :random, false
    limit                 = get_int :limit, 10
    page                  = get_int :page, 1

    @subjects = Subject.by_workflow(workflow_id).active.page(page).per(limit)

    # Filter by subject set?
    @subjects = @subjects.by_parent_subject(parent_subject_id) if parent_subject_id

    # Randomize?
    @subjects = @subjects.random(limit: limit) if random

    # If user/guest active, filter out anything already classified:
    @subjects = @subjects.user_has_not_classified user.id.to_s if ! user.nil?

    links = {
      "next" => {
        href: @subjects.next_page.nil? ? nil : url_for(controller: 'subjects', page: @subjects.next_page),
      },
      "prev" => {
        href: @subjects.prev_page.nil? ? nil : url_for(controller: 'subjects', page: @subjects.prev_page)
      }
    }
    respond_with SubjectResultSerializer.new(@subjects, scope: self.view_context), workflow_id: workflow_id, links: links
  end

  def show
    subject_id  = params["subject_id"]
    @subject = Subject.find_by( _id: params[:subject_id] )
    respond_with  @subject
  end



end
