class Subject
  include Mongoid::Document
  include Mongoid::Timestamps
  include Randomizer

  paginates_per 3

  scope :root, -> { where(type: 'root').asc(:order) }
  scope :active_root, -> { where(type: 'root', status: 'active').asc(:order) }
  scope :active_non_root, -> { where(:type.ne => 'root', :status => 'active') }
  scope :active, -> { where(status: 'active').asc(:order)  }
  scope :complete, -> { where(status: 'complete').asc(:order)  }
  scope :by_workflow, -> (workflow_id) { where(workflow_id: workflow_id)  }
  scope :by_parent_subject_set, -> (parent_subject_set_id) { where(parent_subject_set_id: parent_subject_set_id)  }
  scope :by_parent_subject, -> (parent_subject_id) { where(parent_subject_id: parent_subject_id) }
  scope :by_group, -> (group_id) { where(group_id: group_id) }
  scope :user_has_not_classified, -> (user_id) { where(:classifying_user_ids.ne => user_id)  }

  # This is a hash with one entry per deriv; `standard', 'thumbnail', etc
  field :location,                    type: Hash
  field :type,                        type: String,  default: "root" #options: "root", "secondary"
  field :status,                      type: String,  default: "active" #options: "active", "inactive", "bad", "retired", "complete", "contentious"

  field :meta_data,                   type: Hash
  field :secondary_subject_count,     type: Integer, default: 0
  field :classification_count,        type: Integer, default: 0
  field :random_no,                   type: Float
  field :secondary_subject_count,     type: Integer, default: 0
  field :created_by_user_id,          type: String

  # Need to sort out relationship between these two fields. Are these two fields Is this :shj
  field :retire_count,                type: Integer
  field :flagged_bad_count,           type: Integer
  field :flagged_illegible_count,     type: Integer


  # ROOT SUBJECT concerns:
  field :order
  field :name,                        type: String
  field :width
  field :height

  # SECONDARY SUBJECT concerns:
  field :data,                        type: Hash
  field :region,                      type: Hash

  # Denormalized array of user ids that have classified this subject for quick filtering
  field :classifying_user_ids,        type: Array, default: []
  field :deleting_user_ids,        type: Array, default: []

  belongs_to :workflow
  belongs_to :group
  belongs_to :parent_subject, :class_name => "Subject", :foreign_key => "parent_subject_id"
  belongs_to :subject_set, :class_name => "SubjectSet", :foreign_key => "subject_set_id"

  has_many :child_subjects, :class_name => "Subject"
  has_many :classifications, inverse_of: :subject
  has_many :favourites

  # Classifications that generated this subject:
  has_many :parent_classifications, class_name: 'Classification', inverse_of: :child_subject

  after_create :update_subject_set_stats
  after_create :increment_parents_subject_count_by_one, :if => :parent_subject

  def thumbnail
    location['thumbnail'].nil? ? location['standard'] : location['thumbnail']
  end
  
  def update_subject_set_stats
    subject_set.inc_subject_count_for_workflow(workflow) if ! workflow.nil?
  end

  def increment_parents_subject_count_by(count)
    parent_subject.inc(secondary_subject_count: count)
  end

  def increment_parents_subject_count_by_one
    increment_parents_subject_count_by 1
  end

  def increment_retire_count_by_one
    self.inc(retire_count: 1)
    self.check_retire_by_vote
  end

  def increment_flagged_bad_count_by_one
    self.inc(flagged_bad_count: 1)
    self.check_flagged_bad_count
  end

  def increment_flagged_illegible_count_by_one
    self.inc(flagged_illegible_count: 1)
    # AMS: not in place yet.
    # self.flagged_illegible_count
  end

  # Get the workflow task that generated this subject, if any
  def parent_workflow_task
    if ! (_classifications = parent_classifications.limit(1)).empty?
      _classifications.first.workflow_task
    end
  end

  # find all the classifications for subject where task_key == compleletion_assesment_task
  # calculate the percetage vote for retirement (pvr)
  # if pvr is equal or greater than retire_limit, set self.status == retired.
  def check_flagged_bad_count
    if flagged_bad_count >= 3
      self.bad!
      increment_parents_subject_count_by -1 if parent_subject
    end
  end

  # find all the classifications for subject where task_key == compleletion_assesment_task
  # calculate the percetage vote for retirement (pvr)
  # if pvr is equal or greater than retire_limit, set self.status == retired.
  def check_retire_by_vote
    assesment_classifications = classifications.where(task_key: "completion_assessment_task").count
    if assesment_classifications > 2
      percentage_for_retire = retire_count / assesment_classifications.to_f
      if percentage_for_retire >= workflow.retire_limit
        self.retire!
        increment_parents_subject_count_by -1 if parent_subject
      end
    end
  end


  def bad!
    status! 'bad'
    subject_set.subject_deactivated_on_workflow(workflow) if ! workflow.nil?
  end

  def retire!
    status! 'retired'
    subject_set.subject_completed_on_workflow(workflow) if ! workflow.nil?
  end

  def activate!
    status! 'active'
    self.subject_set.subject_activated_on_workflow(workflow) if ! workflow.nil?
  end

  def calculate_most_popular_parent_classification
    annotations = parent_classifications.map { |c| c.annotation }
    buckets = annotations.inject({}) do |h, ann|
      h[ann] ||= 0
      h[ann] += 1
      h
    end
    buckets = buckets.sort_by { |(k,v)| - v }
    buckets.map { |(k,v)| {ann: k, percentage: v.to_f / parent_classifications.count } }.first
  end


  def to_s
    "#{status != 'active' ? "[#{status.capitalize}] " : ''}#{workflow.nil? ? 'Final' : workflow.name.capitalize} Subject (#{type})"
  end

  private

  def status!(status)
    self.status = status
    save
  end
end
