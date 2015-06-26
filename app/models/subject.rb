class Subject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Randomizer


  scope :active_root, -> { where(type: 'root', status: 'active') }
  scope :active, -> { where(status: 'active') }

  # This is a hash with one entry per deriv; `standard', 'thumbnail', etc
  field :location,                    type: Hash 
  field :type,                        type: String,  default: "root" #options: "root", "secondary"
  field :status,                      type: String,  default: "active" #options: "active", "inactive", "retired", "complete", "contentious"

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
  field :data,                        type: Hash
  field :region,                      type: Hash

  belongs_to :workflow
  belongs_to :parent_subject, :class_name => "Subject", :foreign_key => "parent_subject_id"  
  belongs_to :subject_set, :class_name => "SubjectSet", :foreign_key => "subject_set_id"

  has_many :child_subjects, :class_name => "Subject"
  has_many :classifications
  has_many :favourites

  after_create :update_subject_set_stats, :activate! # this method before :increment_parents_subject_count_by_one
  after_create :increment_parents_subject_count_by_one, :if => :parent_subject

  def source_classifications
    Classification.by_child_subject id
  end

  def update_subject_set_stats
    subject_set.inc_subject_count_for_workflow(workflow) if ! workflow.nil?
  end

  def increment_parents_subject_count_by_one
    parent_subject.inc(secondary_subject_count: 1)
  end

  def increment_retire_count_by_one
    self.inc(retire_count: 1)
    self.retire_by_vote!
  end

  # find all the classifications for subject where task_key == compleletion_assesment_task
  # calculate the percetage vote for retirement (pvr)
  # if pvr is equal or greater than retire_limit, set self.status == retired.
  def retire_by_vote!
    assesment_classifications = classifications.where(task_key: "completion_assessment_task").to_a
    if assesment_classifications.length > 2
      percentage_for_retire = retire_count/assesment_classifications.length.to_f   
      if percentage_for_retire >= workflow.retire_limit
        self.retire!
      end
    end

  end

  def retire!
    self.status = "retired" 
    subject_set.subject_completed_on_workflow(workflow) if ! workflow.nil?
    save
  end

  def activate!
    self.status = "active"
    self.subject_set.subject_activated_on_workflow(workflow) if ! workflow.nil?
    save
  end

  def to_s
    "#{workflow.name.capitalize} Subject (#{type})"
  end
end
