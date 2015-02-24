class Classification
  include Mongoid::Document
  include Mongoid::Timestamps

  field :workflow_id#,   type: ObjectId
  field :subject_id#,    type: ObjectId
  field :location,      type: String
  field :annotations,   type: Object
  field :started_at,    type: Date
  field :finished_at,   type: Date
  field :user_agent,    type: String

  belongs_to :workflow
  belongs_to :user
  belongs_to :subject

  after_save :generate_new_subjects

  def generate_new_subjects

  end

end
