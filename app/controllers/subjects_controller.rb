class SubjectsController < ApplicationController
  respond_to :json

  def index
    puts "SUBJECT CONTROLLLER"
    puts "SUBJECT CONTROLLLER"
    puts "SUBJECT CONTROLLLER"
    puts "SUBJECT CONTROLLLER"
    # @users = User.order(:name).page params[:page]

    workflow_id  = params["workflow_id"]
    parent_subject_id = params["parent_subject_id"]
    random = params["random"] || false
    limit = params["limit"].to_i || 10

    # TO DO: REFACTOR THIS UGLY CODE. -STI
    if parent_subject_id
      @subject = Kaminari.paginate_array(Subject.active.where(workflow_id: workflow_id, parent_subject_id: parent_subject_id)).page(params[:page])
      respond_with @subject
      # respond_with Subject.active.where(workflow_id: workflow_id, parent_subject_id: parent_subject_id).page params[:page]
    else
      # Randomizer#random seems to want query criteria passed in under :selector key:
    	if random
        @subject = Kaminari.paginate_array(Subject.active.where(workflow_id: workflow_id).random(limit: limit)).page(params[:page])
        respond_with @subject
        # respond_with Subject.active.where(workflow_id: workflow_id).random(limit: limit).page params[:page]
      else
        @subject = Kaminari.paginate_array(Subject.active.where(workflow_id: workflow_id).limit(limit)).page(params[:page])
        respond_with @subject 
        # respond_with Subject.active.where(workflow_id: workflow_id).limit(limit).page params[:page]
      end
    end
    puts "@subject: #{@subject}"
  end

  def show
    puts "SUBJECT CONTROLLLER"
    puts "SUBJECT CONTROLLLER"
    puts "SUBJECT CONTROLLLER"
    puts "SUBJECT CONTROLLLER"
    subject_id  = params["subject_id"]
    @subject = Subject.find_by( _id: params[:subject_id] )
    respond_with  @subject
  end



end
