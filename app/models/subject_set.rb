class SubjectSet
  include Mongoid::Document
  include Mongoid::Timestamps
  include Randomizer

  field :name,                   type: String
  field :random_no ,             type: Float
  field :state ,                 type: String, default: "active"
  field :thumbnail,              type: String
  field :meta_data,              type: Hash
  field :counts,                 type: Hash

  belongs_to :group
  has_many :subjects, dependent: :destroy

  def activate!
    state = "active"
    workflows.each{|workflow| workflow.inc(:active_subjects => 1 )}
    save
  end


  def inc_subject_count_for_workflow(workflow)
    inc "counts.#{workflow.id.to_s}.total_subjects" => 1
  end

  def subject_activated_on_workflow(workflow)
    inc "counts.#{workflow.id.to_s}.active_subjects" => 1
  end

  def subject_completed_on_workflow(workflow)
    inc "counts.#{workflow.id.to_s}.complete_subjects" => -1, "counts.#{workflow.id.to_s}.active_subjects" => -1
  end

  def active_subjects_for_workflow(workflow)
    subject.active.for_workflow(workflow)
  end
end
