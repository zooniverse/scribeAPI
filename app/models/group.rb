class Group
  include Mongoid::Document
  include Randomizer

  field :name, type: String
  field :description, type: String
  field :random_no , type: Float

  field :classification_count, type: Integer, default: 0
  field :state , type: String, default: "active"
  field :meta_data,   type: Hash

  has_many :subjects 

  def select_random_subject
    subjects.first
  end

  
end
