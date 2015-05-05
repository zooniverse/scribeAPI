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

  # discuss this later
  def subject_has_enough_classifications(subject)
    subject.classifications.length >= generate_new_subjects_at_classification_count
  end


  def create_secondary_subjects(classification)
    parent_subject_id = classification.subject.id
    subject_set_id = classification.subject.subject_set.id
    workflow_id = project.workflows.find_by(name: "transcribe").id

    puts 'ANNOTATION: ', classification.annotations

    classification.annotations.each do |annotation|
      puts 'ANNOTATION: ', annotation
      if annotation["generate_subjects"]
        annotation["value"].each do |value|
          child_subject = Subject.create(
            workflow_id: workflow_id ,
            subject_set_id: subject_set_id,
            retire_count: 3,
            parent_subject_id: parent_subject_id,
            tool_task_description: annotation["tool_task_description"],
            type: annotation["subject_type"],
            location: {
              standard: classification.subject.file_path,
              spec: value.except(:key, :tool)
            }
          )
        # this allows a generated subject's id to be returned in case of immediate transcription
        classification.child_subject_id = child_subject.id
        parent_subject = classification.subject
        parent_subject.child_subjects << child_subject
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
