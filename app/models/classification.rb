class Classification
  include Mongoid::Document

  field :workflow_id
  field :subject_id
  field :subject_set_id
  field :location
  field :annotation,                      type: Hash
  field :triggered_followup_subject_ids,  type: Array
  field :child_subject_id

  field :started_at
  field :finished_at
  field :user_agent

  belongs_to :workflow
  belongs_to :user
  belongs_to :subject
  has_many   :triggered_followup_subjects, class_name: "Subject"

  after_create :generate_new_subjects
  after_create :generate_terms

  after_create :increment_subject_classification_count

  def generate_new_subjects
    puts "trigger"
    if workflow.generates_new_subjects
      triggered_followup_subject_ids = workflow.create_follow_up_subjects(self)
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

  # finds number of values associated with each classification
  # TODO: this is duplicating work already done in the worklfow.rb
  # Also, lets make sure that annotation.value is always an array?**
  def no_annotation_values
    counter = 0
    self.annotations.each do |annotation|
      # **so that we can prevent this if-statement
      if annotation["value"].is_a? String
        counter += 1 
      else 
        annotation["value"].each do |value|
          counter += annotation["value"].length
        end
      end
    end
    counter
  end


  # we need to increment self.subject.classification_count by the nummber of values in annotation.
  # new ideas for modeling the annotation.values? the current model feels a bit off.
  def increment_subject_classification_count
    subject = self.subject
    # PB: I think classification_count can just be the number of actual classifications now that there's one classification per task:
    subject.classification_count += 1 # no_annotation_values 
    subject.save
    # subject.retire!
  end

end
