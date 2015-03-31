class SubjectSet
  include Mongoid::Document
  include Mongoid::Timestamps
  include Randomizer

  field :name,                 type: String
  field :random_no ,           type: Float
  field :state ,               type: String, default: "active"
  field :thumbnail,            type: String
  field :meta_data,            type: Hash

  has_and_belongs_to_many :workflows, inverse_of: nil
  belongs_to :group
  has_many :subjects

  def activate!
    state = "active"
    workflows.each{|workflow| workflow.inc(:active_subjects => 1 )}
    save
  end
end
