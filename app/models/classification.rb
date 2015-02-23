class Classification
  include Mongoid::Document
  include Mongoid::Timestamps

  field :workflow_id
  field :subject_id
  field :location
  field :annotations
  field :started_at
  field :finished_at
  field :user_agent

  belongs_to :workflow
  belongs_to :user
  belongs_to :subject

  after_save :generate_new_subjects

  def generate_new_subjects

  end

end
