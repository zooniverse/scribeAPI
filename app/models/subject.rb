class Subject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Randomizer

  field :name,                    type: String
  field :thumbnail,               type: String
  field :file_path
  field :order
  field :width
  field :height
  field :state
  field :location,                type: Hash
  field :random_no ,              type: Float
  field :classification_count,    type: Integer, default: 0
  field :state ,                  type: String,  default: "active"
  field :type,                    type: String,  default: "root"
  field :meta_data,               type: Hash
  field :retire_count,            type: Integer
  field :tool_task_description,   type: Hash

  after_create :update_subject_set_stats

  belongs_to :workflow
  has_many :classifications
  has_many :favourites

  belongs_to :parent_subject, :class_name => "Subject", :foreign_key => "parent_subject_id"  
  has_many :child_subjects, :class_name => "Subject"
  
  belongs_to :subject_set


  def update_subject_set_stats
    subject_set.inc_subject_count_for_workflow(workflow)
  end

  def increment_classification_count_by(no)
    self.classification_count += no
    save
    retire! if self.classification_count >= workflow.retire_limit
  end

  def retire!
    self.state = "done"
    subject_set.subject_completed_on_workflow(workflow)
    save
  end

  def activate!
    self.state = "active"
    subject_set.subject_activated_on_workflow(workflow)
    save
  end
end
