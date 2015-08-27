class Classification
  include Mongoid::Document

  field :location
  field :task_key,                        type: String
  field :annotation,                      type: Hash, default: {}
  field :tool_name

  field :started_at
  field :finished_at
  field :user_agent

  belongs_to    :workflow, :foreign_key => "workflow_id"
  belongs_to    :user
  belongs_to    :subject, foreign_key: "subject_id", inverse_of: :classifications
  belongs_to    :child_subject, class_name: "Subject", inverse_of: :parent_classifications

  after_create  :increment_subject_classification_count, :increment_subject_set_classification_count, :check_for_retirement_by_classification_count
  after_create  :generate_new_subjects
  after_create  :generate_terms

  scope :by_child_subject, -> (id) { where(child_subject_id: id) }
  scope :having_child_subjects, -> { where(:child_subject_id.nin => ['', nil]) }
  scope :not_having_child_subjects, -> { where(:child_subject_id.in => ['', nil]) }

  def generate_new_subjects
    if workflow.generates_subjects
      workflow.create_secondary_subjects(self)
    end
  end

    # AMS: not sure if workflow.generates_subjects_after is the best measure.
    # =>   In addition, we only want to call this for certain subjects (not collect unique.)
    # =>   right now, this mainly applies to workflow.generates_subjects_method == "collect-unique".
  def check_for_retirement_by_classification_count
    # PB: This isn't quite right.. Retires the *parent* subject rather than the subject generated..
    # return nil
    puts "RETIRE CHECK"

    workflow = subject.workflow
    if workflow.generates_subjects_method == "collect-unique"
      if subject.classification_count >= workflow.generates_subjects_after
        puts "retiring because clasification count > ..."
        subject.retire!
      end
    end
  end

  def workflow_task
    workflow.task_by_key task_key
  end

  def generate_terms
    return if annotation.nil?
    annotation.each do |(k,v)|

      # Require a min length of 2 to index:
      next if v.nil? || v.size < 2
      # If task doesn't exist (i.e. completion_assessment_task, flag_bad_subject_task), skip:
      next if workflow_task.nil?

      tool_config = workflow_task.tool_config_for_field k
      next if tool_config.nil?

      # Is field configured to be indexed for "common" autocomplete?
      index_term = ! tool_config['suggest'].nil? && tool_config['suggest'] == 'common'
      next if ! index_term

      # Front- and back-end expect fields to be identifiable by workflow_id
      # and an annotation_key built from the task_key and field key
      #   e.g. "enter_building_address:value"
      key = "#{task_key}:#{k}"

      # puts "Term.index_term! #{workflow_id}, #{key}, #{v}"
      Term.index_term! workflow.id, key, v
    end
  end

  def increment_subject_set_classification_count
    subject.subject_set.inc classification_count: 1
  end

  def increment_subject_classification_count
    # TODO: Probably wrong place to be reacting to completion_assessment_task & flag_bad_subject_task
    # tasks; Should perhaps generalize and place elsewhere
    if self.task_key == "completion_assessment_task" && self.annotation["value"] == "complete_subject"
      subject.increment_retire_count_by_one
    end

    if self.task_key == "flag_bad_subject_task"
      subject.increment_flagged_bad_count_by_one

      # Push user_id onto Subject.deleting_user_ids if appropriate
      Subject.where({id: subject.id}).find_and_modify({"$addToSet" => {deleting_user_ids: user_id.to_s}})
    end

    if self.task_key == "flag_illegible_subject_task"
      subject.increment_flagged_illegible_count_by_one
    end
    subject.inc classification_count: 1

    # Push user_id onto Subject.user_ids using mongo's fast addToSet feature, which ensures uniqueness
    Subject.where({id: subject.id}).find_and_modify({"$addToSet" => {classifying_user_ids: user_id.to_s}})
  end

  def to_s
    ann = annotation.values.select { |v| v.match /[a-zA-Z]/ }.map { |v| "\"#{v}\"" }.join ', '
    ann = ann.truncate 40
    # {! annotation["toolName"].nil? ? " (#{annotation["toolName"]})" : ''}
    workflow_name = workflow.nil? ? '[Orphaned] ' : workflow.name.capitalize
    "#{workflow_name} Classification (#{ ann.blank? ? task_key : ann})"
  end

end
