class Classification
  include Mongoid::Document

  field :workflow_id
  field :subject_id
  field :subject_set_id
  field :location
  field :annotations, type: Array
  field :triggered_followup_subject_ids, type: Array

  field :started_at
  field :finished_at
  field :user_agent

  belongs_to :workflow
  belongs_to :user
  belongs_to :subject
  has_many   :triggered_followup_subjects, class_name: "Subject"

  before_create :generate_new_subjects

  def generate_new_subjects
    if workflow.generates_new_subjects
      triggered_followup_subject_ids = workflow.create_follow_up_subjects(self)
    end
  end

  def increment_classification_count_by_one
    #we need to increment self.subject.classification_count by the nummber of values in annotation.
    subject = self.subject
    subject.classification_count += 1
    subject.save
    # We want the subject itself to know its retire_limit, not the workflow of the subject.
    retire! if self.classification_count >= self.retire_limit
  end

end
