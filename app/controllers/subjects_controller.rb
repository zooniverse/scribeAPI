class SubjectsController < ApplicationController
  respond_to :json

  def index
    user = current_or_guest_user

    workflow_id           = get_objectid :workflow_id
    group_id              = get_objectid :group_id
    subject_set_id        = get_objectid :subject_set_id
    parent_subject_id     = get_objectid :parent_subject_id
    # Note that pagination is kind of useless when randomizing
    random                = get_bool :random, false
    limit                 = get_int :limit, 10
    page                  = get_int :page, 1
    type                  = params[:type]
    # `status` filter must be one of: 'active', 'any'
    status                = ['active','any'].include?(params[:status]) ? params[:status] : 'active'

    @subjects = Subject.page(page).per(limit)

    # Only active subjects?
    @subjects = @subjects.active if status == 'active'

    # Filter by subject type (e.g. 'root')
    @subjects = @subjects.by_type(type) if type

    # Filter by workflow (There should almost always be a workflow_id filter)
    @subjects = @subjects.by_workflow(workflow_id) if workflow_id

    # Filter by subject?
    @subjects = @subjects.by_parent_subject(parent_subject_id) if parent_subject_id

    # Filter by group?
    @subjects = @subjects.by_group(group_id) if group_id

    # Filter by subject set?
    @subjects = @subjects.by_subject_set(subject_set_id) if subject_set_id

    if ! subject_set_id
      # Randomize?
      # @subjects = @subjects.random(limit: limit) if random
      # PB: Above randomization method produces better randomness, but inconsistent totals
      @subjects = @subjects.random_order if random

      # If user/guest active, filter out anything already classified:
      @subjects = @subjects.user_has_not_classified user.id.to_s if ! user.nil?
    end

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
    subject_id = get_objectid :subject_id

    links = {
      self: url_for(@subject)
    }
    @subject = Subject.find subject_id
    respond_with SubjectResultSerializer.new(@subject, scope: self.view_context), links: links
  end


end
