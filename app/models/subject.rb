class Subject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Randomizer


  scope :root_type, -> { where(type: 'root') }

  # This is a hash with one entry per deriv; `standard', 'thumbnail', etc
  field :location,                    type: Hash 
  field :type,                        type: String,  default: "root" #options: "root", "secondary"
  field :status,                      type: String,  default: "active" #options: "active", "inactive", "retired", "complete"

  field :meta_data,                   type: Hash
  field :secondary_subject_count,     type: Integer, default: 0
  field :classification_count,        type: Integer, default: 0
  field :random_no,                   type: Float
  field :secondary_subject_count,     type: Integer, default: 0

  # Need to sort out relationship between these two fields. Are these two fields Is this :shj
  field :retire_count,                type: Integer


  # ROOT SUBJECT concerns:
  field :order
  field :name,                        type: String
  field :width
  field :height

  # SECONDARY SUBJECT concerns:
  field :tool_task_description,       type: Hash
  field :data,                        type: Hash
  field :region,                      type: Hash

  belongs_to :workflow
  belongs_to :parent_subject, :class_name => "Subject", :foreign_key => "parent_subject_id"  
  belongs_to :subject_set

  has_many :child_subjects, :class_name => "Subject"
  has_many :classifications
  has_many :favourites

  after_create :update_subject_set_stats, :activate! # this method before :increment_parents_subject_count_by_one
  after_create :increment_parents_subject_count_by_one, :if => :parent_subject

  def update_subject_set_stats
    subject_set.inc_subject_count_for_workflow(workflow)
  end

  def increment_parents_subject_count_by_one
    parent_subject.inc(secondary_subject_count: 1)
  end

  def increment_retire_count_by_one
    self.inc(retire_count: 1)
  end

  def retire_by_vote!
    self.status = "retired" if (self.retire_count >= self.workflow.retire_limit)
    subject_set.subject_completed_on_workflow(workflow)
    save
  end

  def activate!
    self.status = "active"
    self.subject_set.subject_activated_on_workflow(workflow)
    save
  end

end
