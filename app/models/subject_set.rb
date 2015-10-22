class SubjectSet
  include Mongoid::Document
  include Mongoid::Timestamps
  include Randomizer

  paginates_per 2

  field :key,                    type: String
  field :name,                   type: String
  field :random_no ,             type: Float
  field :state ,                 type: String, default: "active"
  field :thumbnail,              type: String
  field :meta_data,              type: Hash
  field :counts,                 type: Hash
  # Just for admin filtering
  # field :classification_count,   type: Integer, default: 0 #until we have a use case, let us not record this info

  field :complete_secondary_subject_count,    type: Integer, default: 0
  field :active_secondary_subject_count,      type: Integer, default: 0

  belongs_to :group
  belongs_to :project
  has_many :subjects, dependent: :destroy, :order => [:order, :asc]

  # AMS: should a subject_set belong to a workflow, or do we get that throught the subject?
  # I think this is being used in the rake load_group_subjects around line133
  def activate!
    state = "active"
    workflows.each{|workflow| workflow.inc(:active_subjects => 1 )}
    save
  end

=begin
  def inc_active_secondary_subject(amount = 1)
    if amount > 0
      self.inc(:active_secondary_subject_count => amount)
      self.group.inc(:active_secondary_subject_count => amount)
    else
      self.dec(:active_secondary_subject_count => amount)
      self.group.dec(:active_secondary_subject_count => amount)
    end
  end

  def inc_complete_secondary_subject(amount = 1)
    if amount > 0
      self.inc(:complete_secondary_subject_count => amount)
      # self.group.inc(:complete_secondary_subject_count => amount)
    else
      self.dec(:complete_secondary_subject_count => amount)
      # self.group.dec(:complete_secondary_subject_count => amount)
    end
  end
=end

  def inc_subject_count_for_workflow(workflow)
    self.inc("counts.#{workflow.id.to_s}.total_subjects" => 1)
  end

  def subject_deactivated_on_workflow(workflow)
    inc_subjects_on_workflow(workflow, -1)
  end

  def subject_activated_on_workflow(workflow)
    inc_subjects_on_workflow(workflow, 1)
  end

  def inc_subjects_on_workflow(workflow, inc)
    self.inc("counts.#{workflow.id.to_s}.active_subjects" => inc)
  end

  def subject_completed_on_workflow(workflow)
    self.inc("counts.#{workflow.id.to_s}.complete_subjects" => +1)
    self.inc("counts.#{workflow.id.to_s}.active_subjects" => -1)
  end

  # AMS: what is this for?
  def active_subjects_for_workflow(workflow)
    subject.active.for_workflow(workflow)
  end

  def self.autocomplete_name(field, letters)
    reg = /#{Regexp.escape(letters)}/i
    where( project: Project.current, :"meta_data.#{field}" => reg)
  end

  def workflows
    counts.map do |k,v|
      workflow = Workflow.find k
      v.merge workflow: workflow
    end
  end

  def to_s
    "#{state == 'inactive' ? '[Inactive] ' : ''}Subject Set"
  end

end
