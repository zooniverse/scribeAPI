class Classification
  include Mongoid::Document

  field :location
  field :annotations, type: Array
  field :triggered_followup_subject_ids, type: Array

  field :started_at
  field :finished_at
  field :user_agent

  belongs_to    :workflow
  belongs_to    :user
  belongs_to    :subject
  belongs_to    :child_subject, :class_name => "Subject"
  has_many      :triggered_followup_subjects, class_name: "Subject"

  after_create  :increment_subject_classification_count, :check_for_retirement
  after_create  :generate_new_subjects

  def generate_new_subjects
    if workflow.generates_new_subjects
      triggered_followup_subject_ids = workflow.create_secondary_subjects(self)
    end
  end

  def check_for_retirement
    subject.retire_by_vote! if subject.type == "root"
  end  

  def increment_subject_classification_count
    subject.classification_count += 1
    subject.save
  end

end
