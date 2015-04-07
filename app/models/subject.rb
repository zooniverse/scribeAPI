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
  field :state ,               type: String, default: "active"
  field :type,                 type: String, default: "root"
  field :meta_data,            type: Hash

  has_and_belongs_to_many :workflows, inverse_of: nil
  has_many :favourites
  has_one :parent_subject, :class_name => "Subject"
  belongs_to :subject_set

  def increment_classification_count_by(no)
    self.classification_count += no
    save
    retire! if self.classification_count >= workflow.retire_limit
  end

  def retire!
    self.state = "done"
    workflow.inc(:active_subjects => -1 )
    save
  end

  def activate!
    self.state = "active"
    workflow.inc(:active_subjects => 1 )
    save
  end
end
