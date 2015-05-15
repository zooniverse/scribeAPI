class Subject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Randomizer

  # This is a hash with one entry per deriv; `standard', 'thumbnail', etc
  field :location,                    type: Hash 
  field :type,                        type: String,  default: "root" #options: "root", "secondary"
  field :status,                      type: String,  default: "active" #options: "active", "inactive", "retired", "complete"

  field :meta_data,                   type: Hash
  field :secondary_subject_count,     type: Integer, default: 0
  field :classification_count,        type: Integer, default: 0
  field :random_no,                   type: Float

  # TODO PB This is, I believe soon to be renamed to retire_vote:
  field :retire_count,                type: Integer
  # TODO PB This is, I believe, the new retire_count?
  field :retire_vote,                 type: Integer, default: 0

  # ROOT SUBJECT concerns:
  field :order
  field :name,                        type: String
  field :width
  field :height

  # SECONDARY SUBJECT concerns:
  field :tool_task_description,       type: Hash
  field :data,                        type: Hash
  field :region,                      type: Hash

  # field :thumbnail,                   type: String # PB Deprecating this
  # field :file_path # PB Deprecating this
  # Optional 'key' value specified in some tool options (drawing) to identify tool option selected ('record-rect', 'point-tool')
  # field :key,                         type: String # PB Dep
  # field :annotation_value_count,      type: Integer, default: 0 # PB I believe this is deprecated in favor of classification_count:

  belongs_to :workflow
  belongs_to :parent_subject, :class_name => "Subject", :foreign_key => "parent_subject_id"  
  belongs_to :subject_set

  has_many :child_subjects, :class_name => "Subject"
  has_many :classifications
  has_many :favourites

  # after_create :update_subject_set_stats

  after_create :increment_parents_subject_count_by_one, :if => :parent_subject


  def update_subject_set_stats
    subject_set.inc_subject_count_for_workflow(workflow)
  end

  # increment the self.parent.secondary_subject_count by 1
  # check out ink mongomapper
  # sets the proper type value. at the moment this is limited to "secondary" might be more appropiate to say "non-root".
  def increment_parents_subject_count_by_one
    parent_subject = self.parent_subject
    parent_subject.secondary_subject_count += 1
    parent_subject.save
  end

  # Result 1) should set self.status == "retired" under the following condition:
  #   1) user indicated that a subject is completely classified
  #   2) self.annotation_value_count >= self.retire_count
  # Result 2) should decrement the self.parent_subject.secondary_subject_count by 1, if self.status == "retired"
  # def retire!
  #   puts "EVAL"
    # TODO: retirement should be based on workflow, right? --- consult team.
    # self.status = "retired" if self.annotation_value_count >= self.retire_count
    # subject_set.subject_completed_on_workflow(workflow)
  #   save
  # end

  def activate!
    self.status = "active"
    subject_set.subject_activated_on_workflow(workflow)
    save
  end

end
