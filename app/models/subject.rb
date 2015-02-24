class Subject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Randomizer

  field :name,                 type: String
  field :thumbnail,             type: String
  field :file_path
  field :order
  field :width
  field :height
  field :state
  field :location,             type: Hash
  field :random_no ,           type: Float
  field :classification_count, type: Integer, default: 0
  field :retire_count,         type: Integer, default: 0
  field :state ,               type: String, default: "active"
  field :type,                 type: String, default: "root"
  field :meta_data,            type: Hash

  has_and_belongs_to_many :workflows, inverse_of: nil
  has_one :parent_subject, :class_name => "Subject"

  def increment_retire_count_by(no)
    retire_count += no
    save
    retire! if retire_count > workflow.retire_limit
  end

  def retire!
    state = "done"
    workflows.each{|workflow| workflow.inc(:active_subjects => -1 )}
    save
  end

  def activate!
    state = "active"
    workflows.each{|workflow| workflow.inc(:active_subjects => 1 )}
    save
  end
end
