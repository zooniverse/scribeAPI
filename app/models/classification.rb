class Classification
  include Mongoid::Document

  field :workflow_id
  field :subject_id
  field :subject_set_id
  field :location
  field :annotations, type: Array
  field :triggered_followup_subject_ids, type: Array

  field :started_at
  field :finished_at
  field :user_agent

  belongs_to :workflow
  belongs_to :user
  belongs_to :subject
  has_many   :triggered_followup_subjects, class_name: "Subject"

  before_create :generate_new_subjects
  after_create :generate_terms

  def generate_new_subjects
    if workflow.generates_new_subjects
      triggered_followup_subject_ids = workflow.create_follow_up_subjects(self)
    end
  end

  def generate_terms
    annotations.each do |ann|
      next if ann['value'].nil? || ann['value'].size < 3

      # Get tool_options from workflow task config to determine if suggest='common'
      tool_options = workflow.tasks.select { |(key, task)| key == ann['key'] }[ann['key']]['tool_options']
      index_term = ! tool_options['suggest'].nil? && tool_options['suggest'] == 'common'
      next if ! index_term

      Term.index_term! workflow_id, ann['key'], ann['value'] 
    end
  end

end
