class Subject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Randomizer

  field :name,                        type: String
  field :thumbnail,                   type: String
  field :order
  field :width
  field :height
  field :location,                    type: Hash
  field :status,                      type: String,  default: "active" #options: "active", "inactive", "retired", "complete"
  field :type,                        type: String,  default: "root"
  
  field :data,                        type: Hash
  field :region,                      type: Hash
  field :meta_data,                   type: Hash
  field :tool_task_description,       type: Hash
  
  #TODO: can we delete these fields?
  field :file_path
  field :random_no ,                  type: Float
  field :key,                         type: String
  
  field :secondary_subject_count,     type: Integer, default: 0
  field :classification_count,        type: Integer, default: 0
  field :retire_count,                type: Integer
  field :retire_vote,                 type: Integer, default: 0

  belongs_to :workflow
  has_many :classifications
  has_many :favourites
  belongs_to :subject_set
  belongs_to :parent_subject, :class_name => "Subject", :foreign_key => "parent_subject_id"
  has_many :child_subjects, :class_name => "Subject"

  after_create :update_subject_set_stats

  after_create :increment_parents_subject_count_by_one, :if => :parent_subject


  def update_subject_set_stats
    subject_set.inc_subject_count_for_workflow(workflow)
  end

  def increment_parents_subject_count_by_one
    parent_subject.inc(secondary_subject_count: 1)
  end

  def retire!
    self.status = "retired" if classification_count >= retire_count
    subject_set.subject_completed_on_workflow(workflow)
    save
  end

  def activate!
    self.status = "active"
    subject_set.subject_activated_on_workflow(workflow)
    save
  end

end
