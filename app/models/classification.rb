class Classification
  include Mongoid::Document

  field :location
  field :task_key,                        type: String
  field :annotation #, type: Array
  field :tool_name

  #TODO: don't think this is being used? AMS
  field :triggered_followup_subject_ids,  type: Array

  field :started_at
  field :finished_at
  field :user_agent

  belongs_to    :workflow, :foreign_key => "workflow_id"
  belongs_to    :user
  belongs_to    :subject, :foreign_key => "subject_id"
  belongs_to    :child_subject, :class_name => "Subject"
  has_many      :triggered_followup_subjects, class_name: "Subject"

  after_create  :increment_subject_classification_count
  after_create  :generate_new_subjects
  after_create  :generate_terms

  scope :by_child_subject, -> (id) { where(child_subject_id: id) }
  scope :having_child_subjects, -> { where(:child_subject_id.nin => ['', nil]) }
  scope :not_having_child_subjects, -> { where(:child_subject_id.in => ['', nil]) }

  def generate_new_subjects
    if workflow.generates_subjects
      triggered_followup_subject_ids = workflow.create_secondary_subjects(self)
    end
  end

    # AMS: not sure if workflow.generates_subjects_after is the best measure.
    # =>   In addition, we only want to call this for certain subjects (not collect unique.)
    # =>   right now, this mainly applies to workflow.generates_subjects_method == "collect-unique".
  def check_for_retirement_by_classification_count
    workflow = subject.workflow
    if workflow.generates_subjects_method == "collect-unique"
      subject.classification_count >= workflow.generates_subjects_after
        subject.retire!
      end
    end
  end  

  def generate_terms
    # TODO: update this to work with annotation; previously written for annotations
    return 
    annotations.each do |ann|
      puts " considering: #{ann.inspect}"
      anns = [{val: ann['value'], key: ann['key']}]
      if anns.first[:val].is_a? Hash
        anns = ann['value'].map { |(k, v)| {val: v, key: k} }
      end
      puts "got anns: #{anns.inspect}"

      anns.each do |sub_ann|
        next if sub_ann[:val].nil? || sub_ann[:val].size < 3

        # Get tool_config from workflow task config to determine if suggest='common'
        task = workflow.tasks.select { |(key, task)| key == ann['key'] }.map { |p| p[1]}.first
        puts " index? #{task.inspect}.... #{sub_ann[:key]}"
        next if task.nil?
        # tool_config = task[ann['key']]['tool_config']
        tool_config = task['tool_config']

        puts " index? ", tool_config
        index_term = ! tool_config['suggest'].nil? && tool_config['suggest'] == 'common'
        puts " index? ", index_term
        next if ! index_term

        puts "Term.index_term! #{workflow_id}, #{sub_ann[:key]}, #{sub_ann[:val]}"
        Term.index_term! workflow_id, sub_ann[:key], sub_ann[:val] 
      end
    end
  end

  def increment_subject_classification_count
    subject = self.subject
    #increment subject.retire_count if the completion_assement_task returns annoation 'complete_subject'
    if self.task_key == "completion_assessment_task" && self.annotation["value"] == "complete_subject"
      subject.increment_retire_count_by_one 
    end
    subject.classification_count += 1 # no_annotation_values 
    subject.save
  end

  def to_s
    "#{workflow.name.capitalize} Classification"
  end

end
