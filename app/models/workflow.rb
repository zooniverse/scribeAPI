class Workflow
  include Mongoid::Document

  field    :name,                                            type: String
  field    :key, 				                                     type: String
  field    :label,                                           type: String
  field    :tasks, 			      	                             type: Hash
  field    :first_task,                                      type: String
  field    :retire_limit, 		                               type: Integer, default: 10
  field    :enables_workflows,                               type: Hash
  field    :active_subjects,                                 type: Integer, default: 0
  field    :generates_new_subjects,                          type: Boolean, default: false
  field    :generate_new_subjects_at_classification_count,   type: Integer, default: 1
  field    :subject_fetch_limit,                             type: Integer, default: 10


  has_many     :subjects
  has_many     :classifications
  belongs_to   :project

  def trigger_follow_up_workflows(subject)
    follow_up_subjects = []

  	enables_workflows.each_pair do |workflow_id, denormed_fields|
      follow_up_subjects << Workflow.find(workflow_id).create_follow_up_subject(subject, denormed_fields)
  	end

    follow_up_subjects
  end

  def subject_has_enough_classifications(subject)
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    subject.classifications.length >= generate_new_subjects_at_classification_count
  end


  def create_secondary_subjects(classification)
    # for each value in annotation
    primary_subject_id = classification.subject.id
    subject_set_id = classification.subject.subject_set.id
    binding.pry
    workflow_id = Workflow.find_by(name: "transcribe").id

    classification.annotations.each do |annotation|
      if annotation["generate_subjects"]
        annotation["value"].each do |value|
          Subject.create(
            workflow_id: workflow_id ,
            subject_set_id: subject_set_id,
            retire_count: 3,
            width: value["width"],
            height: value["height"],
            meta_data: {primary_subject_id: primary_subject_id, x: value["x"], y: value["y"], }
            )
        end
      end

    end
  end

  def create_follow_up_subjects(classification)
    return unless generates_new_subjects
    return unless subject_has_enough_classifications(classification.subject)
    create_secondary_subjects(classification)
    #trigger_follow_up_workflows(classification.subject)
  end
end
