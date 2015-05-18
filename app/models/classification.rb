class Classification
  include Mongoid::Document

  field :location
  field :annotations, type: Array
  field :triggered_followup_subject_ids, type: Array

  field :started_at
  field :finished_at
  field :user_agent

  belongs_to    :workflow
  belongs_to    :user
  belongs_to    :subject
  belongs_to    :child_subject, :class_name => "Subject"
  has_many      :triggered_followup_subjects, class_name: "Subject"

  after_create  :increment_subject_classification_count, :check_for_retirement
  after_create  :generate_new_subjects
  after_create :generate_terms

  after_create :increment_subject_classification_count


  def generate_new_subjects
    if workflow.generates_new_subjects
      triggered_followup_subject_ids = workflow.create_secondary_subjects(self)
    end
  end

  def check_for_retirement
    subject.retire_by_vote! if subject.type == "root"
  end  

  def generate_terms
    annotations.each do |ann|
      puts " considering: #{ann.inspect}"
      anns = [{val: ann['value'], key: ann['key']}]
      if anns.first[:val].is_a? Hash
        anns = ann['value'].map { |(k, v)| {val: v, key: k} }
      end
      puts "got anns: #{anns.inspect}"

      anns.each do |sub_ann|
        next if sub_ann[:val].nil? || sub_ann[:val].size < 3

        # Get tool_options from workflow task config to determine if suggest='common'
        task = workflow.tasks.select { |(key, task)| key == ann['key'] }.map { |p| p[1]}.first
        puts " index? #{task.inspect}.... #{sub_ann[:key]}"
        next if task.nil?
        # tool_options = task[ann['key']]['tool_options']
        tool_options = task['tool_options']

        puts " index? ", tool_options
        index_term = ! tool_options['suggest'].nil? && tool_options['suggest'] == 'common'
        puts " index? ", index_term
        next if ! index_term

        puts "Term.index_term! #{workflow_id}, #{sub_ann[:key]}, #{sub_ann[:val]}"
        Term.index_term! workflow_id, sub_ann[:key], sub_ann[:val] 
      end
    end
  end

  def increment_subject_classification_count
    subject.classification_count += 1
    subject.save
  end

end
