class SubjectsController < ApplicationController
  respond_to :json

  def index
    # @users = User.order(:name).page params[:page]

    workflow_id           = get_objectid :workflow_id
    parent_subject_id     = get_objectid :parent_subject_id
    random                = get_bool :random, false
    limit                 = get_int :limit, 10
    page                  = get_int :page, 1
    puts "parse page: #{page}"

    @subjects = Subject.by_workflow(workflow_id).active

    @subjects = @subjects.by_parent_subject(parent_subject_id) if parent_subject_id
    
    @subjects = @subjects.random(limit: limit) if random

    @subjects = @subjects.page(page).per(limit)

    links = {
      "next" => {
        href: @subjects.next_page.nil? ? nil : url_for(controller: 'subjects', page: @subjects.next_page),
      },
      "prev" => {
        href: @subjects.prev_page.nil? ? nil : url_for(controller: 'subjects', page: @subjects.prev_page)
      }
    }
    respond_with SubjectResultSerializer.new(@subjects), workflow_id: workflow_id, links: links

  end

  def show
    subject_id  = params["subject_id"]
    @subject = Subject.find_by( _id: params[:subject_id] )
    respond_with  @subject
  end



end
