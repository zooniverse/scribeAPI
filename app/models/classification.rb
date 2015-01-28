class Classification
  include Mongoid::Document
<<<<<<< Updated upstream
  
  field :annotations
=======

  field :annotations, type: Array
  field :triggered_followup_subject_ids, type: Array
>>>>>>> Stashed changes

  belongs_to :workflow
  belongs_to :user
  belongs_to :subject
  has_many   :triggered_followup_subjects, as: :subject

  before_create :generate_new_subjects

  def generate_new_subjects
    if workflow.generates_new_subjects
      triggered_followup_subject_ids = workflow.create_follow_up_subjects(self)
    end
  end

end
