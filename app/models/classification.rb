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
  has_many   :triggered_followup_subjects, class_name: "Subject"

  before_create :generate_new_subjects
  after_create :increment_subject_number_of_annontation_values

  def generate_new_subjects
    if workflow.generates_new_subjects
      triggered_followup_subject_ids = workflow.create_follow_up_subjects(self)
    end
  end

  # finds number of values associated with each classification
  # TODO: this is duplicating work already done in the worklfow.rb
  # Also, lets make sure that annotation.value is always an array?**
  def no_annotation_values
    counter = 0
    self.annotations.each do |annotation|
      # **so that we can prevent this if-statement
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


  # we need to increment self.subject.classification_count by the nummber of values in annotation.
  # new ideas for modeling the annotation.values? the current model feels a bit off.
  def increment_subject_number_of_annontation_values
    subject = self.subject
    subject.annotation_value_count += no_annotation_values
    subject.save
    # subject.retire!
  end

end
