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
    subject.classification_count >= generate_new_subject_at_classification_count
  end

  def create_follow_up_subjects(classification)
    return unless generate_new_subject
    return unless subject_has_enough_classifications
    trigger_follow_up_workflows(classification.subject)
  end
end
