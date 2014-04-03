class Subject 
  include Mongoid::Document
  include Randomizer


  field :name, type: String
  field :url , type: String
  field :random_no , type: Float
  field :classification_count, type: Integer, default: 0
  field :retire_count, type: Integer, default: 0
  field :state , type: String, default: "active"
  field :type,   type: String, default: "root" 
  field :metadata,   type: Hash



  has_and_belongs_to_many :workflows, inverse_of: nil
  has_one :parent_subject, :class_name => "Subject"

  def increment_retire_count_by(no)
    retire_count += 1
    save
    retire! if retire_count > workflow.retire_limit
  end

  def retire!
    state="inactive"
    save
  end
end

