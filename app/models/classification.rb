class Classification
  include Mongoid::Document

  field :location
  field :annotations, type: Array
  field :triggered_followup_subject_ids, type: Array

  field :started_at
  field :finished_at
  field :user_agent

  belongs_to :workflow
  belongs_to :user
  belongs_to :subject
  belongs_to  :child_subject, :class_name => "Subject"
  has_many   :triggered_followup_subjects, class_name: "Subject"

  after_create :increment_subject_classification_count, :check_for_retirement
  after_create :generate_new_subjects

  def generate_new_subjects
    if workflow.generates_new_subjects
      triggered_followup_subject_ids = workflow.create_secondary_subjects(self)
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

  def check_for_retirement
    subject.retire_by_vote! if subject.type == "root"
  end  

  def increment_subject_classification_count
    subject.classification_count += no_annotation_values #the method can now be replaced by self.annotations.length
    subject.save
  end

end
