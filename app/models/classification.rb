class Classification
  include Mongoid::Document

  field :workflow_id
  field :subject_id
  field :subject_set_id
  field :location
  field :annotations, type: Array
  field :triggered_followup_subject_ids, type: Array
  field :child_subject_id

  field :started_at
  field :finished_at
  field :user_agent

  belongs_to :workflow
  belongs_to :user
  belongs_to :subject
  #belong_to :child_subject, 
  has_many   :triggered_followup_subjects, class_name: "Subject"

  after_create :increment_subject_classification_count
  after_create :generate_new_subjects

  def generate_new_subjects
    if workflow.generates_new_subjects
      triggered_followup_subject_ids = workflow.create_follow_up_subjects(self)
    end
  end

  # finds number of values associated with each classification
  # TODO: this should reflect the new classification model!!!
  ####### aka shouldn't need to check annotation[value], just annotation.
  def no_annotation_values
    counter = 0
    self.annotations.each do |annotation|
      if annotation["value"].is_a? String
        counter += 1 
      else 
        annotation["value"].each do |value|
          counter += annotation["value"].length
        end
      end
    end
    counter
  end

  def increment_subject_classification_count
    subject = self.subject
    subject.classification_count += no_annotation_values
    subject.save
    # check to see if subject.type == "root" 
    # subject.retire! # we are still working out retirement implementation
  end

end
