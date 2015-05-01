class Subject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Randomizer

  field :name,                      type: String
  field :thumbnail,                 type: String
  field :file_path
  field :order
  field :width
  field :height
  field :state
  field :location,                  type: Hash
  field :random_no ,                type: Float
  field :classification_count,      type: Integer, default: 0
  field :status ,                   type: String,  default: "active"
  field :type,                      type: String,  default: "root"
  field :meta_data,                 type: Hash
  field :retire_limit,              type: Integer
  field :tool_task_description,     type: Hash

  # Optional 'key' value specified in some tool options (drawing) to identify tool option selected ('record-rect', 'point-tool')
  field :key,                     type: String

  belongs_to :workflow
  has_many :classifications
  has_many :favourites

  belongs_to :parent_subject, :class_name => "Subject", :foreign_key => "parent_subject_id"  
  has_many :child_subjects, :class_name => "Subject"
  
  belongs_to :subject_set

  # after_create :update_subject_set_stats

  after_save :increment_classification_count_by_one, :if => :parent_subject


  def update_subject_set_stats
    subject_set.inc_subject_count_for_workflow(workflow)
  end

  def increment_classification_count_by_one
    parent_subject = self.parent_subject
    parent_subject.classification_count += 1
    parent_subject.save
    # We want the subject itself to know its retire_limit, not the workflow.
    retire! if self.classification_count >= self.retire_limit
  end

  def retire!
    self.status = "retired"
    subject_set.subject_completed_on_workflow(workflow)
    save
  end

  def activate!
    self.state = "active"
    subject_set.subject_activated_on_workflow(workflow)
    save
  end
end
