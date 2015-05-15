class Workflow
  include Mongoid::Document

  field    :name,                                            type: String
  field    :key, 				                                     type: String
  field    :label,                                           type: String
  field    :tasks, 			      	                             type: Hash
  field    :first_task,                                      type: String
  field    :retire_limit, 		                               type: Integer,   default: 10
  field    :subject_fetch_limit,                             type: Integer,   default: 10
  field    :generates_new_subjects,                          type: Boolean,   default: false
  field    :generate_subjects_after,                         type: Integer,   default: 0
  field    :generates_subjects_for,                          type: String,    default: ""
  field    :generate_subjects_max,                           type: Integer
  field    :active_subjects,                                 type: Integer, default: 0


  has_many     :subjects
  has_many     :classifications
  belongs_to   :project

  # def trigger_follow_up_workflows(subject)
  #   follow_up_subjects = []

  # 	enables_workflows.each_pair do |workflow_id, denormed_fields|
  #     follow_up_subjects << Workflow.find(workflow_id).create_follow_up_subject(subject, denormed_fields)
  # 	end

  #   follow_up_subjects
  # end

  def subject_has_enough_classifications(subject)
    subject.classification_count >= self.generate_subjects_after
  end


  def create_secondary_subjects(classification)   

    workflow_for_new_subject = Workflow.find_by(name: classification.subject.workflow.generates_subjects_for).id
    classification.annotations.each do |annotation|
      if annotation["generate_subjects"]
        annotation["value"].each do |value|
          child_subject = Subject.create(
            workflow: workflow_for_new_subject,
            subject_set: classification.subject.subject_set,
            # TODO discuss how this will be implemented!!
            # retire_count: workflow_for_new_subject.retire_limit,
            parent_subject_id: classification.subject_id,
            tool_task_description: annotation["tool_task_description"],
            type: annotation["subject_type"],
            location: {
              standard: classification.subject.file_path,
            },
            data: value.except(:key, :tool),
            type: annotation["tool_task_description"]["generated_subject_type"]
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
    return unless self.generates_new_subjects
    return unless subject_has_enough_classifications(classification.subject)
    create_secondary_subjects(classification)
  end
end
