class Workflow
  include Mongoid::Document

  field    :name,                                            type: String
  #TODO: can we delete :key field?
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
    return unless self.generates_new_subjects
    return unless subject_has_enough_classifications(classification.subject)

    workflow_for_new_subject = Workflow.find_by(name: classification.subject.workflow.generates_subjects_for).id
    classification.annotations.each do |annotation|
      if annotation["generate_subjects"]
        annotation["value"].each do |value|
          child_subject = Subject.create(
            workflow: workflow_for_new_subject,
            subject_set: classification.subject.subject_set,
            parent_subject_id: classification.subject_id,
            tool_task_description: annotation["tool_task_description"],
            type: annotation["subject_type"],
            location: {
              standard: classification.subject.file_path,
            },
            # TODO: region field for tiertiary subjects, filling it with parent_subject.data?
            data: value.except(:key, :tool),
            type: annotation["tool_task_description"]["generated_subject_type"]
          )
        child_subject.activate!
        classification.child_subject = child_subject
        classification.save
        child_subject
        end
      end
    end
    
  end

  
end
