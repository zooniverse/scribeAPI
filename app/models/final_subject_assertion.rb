class FinalSubjectAssertion
  include Mongoid::Document

  field :name,                          type: String
  field :status,                        type: String
  field :created_in_workflow,           type: String
  field :confidence,                    type: Float
  field :data,                          type: Hash
  field :versions,                      type: Array
  field :region,                        type: Hash
  field :task_key,                      type: String
  field :instructions,                  type: Hash

  belongs_to :root_subject, class_name: "Subject"

  embedded_in :final_subject, inverse_of: :assertions

  def self.create_from_subject(subject, parents)
    inst = new

    inst.name = subject.export_name
    inst.status = status_for_subject(subject)
    inst.created_in_workflow = subject.parent_workflow.nil? ? nil : subject.parent_workflow.name
    inst.confidence = confidence_for_subject(subject)
    inst.data = data_for_subject(subject)
    inst.versions = classifications_for_subject(subject)
    inst.region = region_for_subject(subject)
    inst.task_key = subject.parent_classifications.empty? ? nil : subject.parent_classifications.limit(1).first.task_key
    inst.instructions = instructions_for_subject(subject, parents)

    inst
  end

  def self.classifications_for_subject(subject)
    # Hack to show all distinct classifications with counts for terminal subjects being transcribed:
    # if object[:subject].parent_workflow.name == 'transcribe'
    
    annotations_with_confidence subject if ! subject.parent_workflow.nil? && subject.parent_workflow.name != 'mark'
  end

  def self.instructions_for_subject(subject, parents)
    ret = {}

    parents.each do |s|
      next if s.parent_workflow.nil?

      if s.parent_workflow.name == 'mark' && subject.region && subject.region[:label]
        ret[s.parent_workflow.name] = subject.region[:label]

      else
        ret[s.parent_workflow.name] = s.parent_workflow_task.instruction
      end
    end
    ret[subject.parent_workflow.name] = subject.parent_workflow_task.instruction if ! subject.parent_workflow.nil?
    ret
  end

  def self.region_for_subject(subject)
    region = subject.region
    return nil if region.nil?

    # not important:
    region.delete 'color'

    # Translate toolName to generic 'shape' name:
    region[:shape] = case region[:toolName]
      when 'rectangleTool','rowTool' then 'rectangle'
      when 'pointTool' then 'point'
    end
    region.delete 'toolName'

    region
  end

  def self.data_for_subject(subject)
    data = nil
    if ['complete','retired'].include? subject.status
      data = subject.data
    else
      cl = annotations_with_confidence(subject).first
      data = cl.nil? ? nil : cl[:data]
    end
    data = data['values'].first if data && data['values']
    
    data 
  end

  def self.confidence_for_subject(subject)
    if subject.status == 'complete'
      1
    elsif subject.status == 'retired'
      1
    else
      annotations_with_confidence(subject).map { |a| a[:confidence] }.max
    end
  end

  def self.status_for_subject(subject)
    return nil if subject.parent_workflow.nil?

    return 'complete' if subject.status == 'complete'

    if subject.parent_workflow.name == 'transcribe'
      return 'awaiting_transcriptions' if subject.status == 'inactive'
      return 'awaiting_votes' if subject.status == 'active'

    elsif subject.parent_workflow.name == 'verify'
      return 'awaiting_votes' if subject.status == 'inactive'
    end

    subject.status
  end


  def self.annotations_with_confidence(subject)
    num_votes = [subject.parent_workflow.nil? ? 3 : subject.parent_workflow.generates_subjects_after, subject.parent_classifications.count].max
    grouped = subject.parent_classifications.inject({}) { |h, c| h[c.annotation] ||= 0; h[c.annotation] += 1; h }
    classifications_by_annotation = subject.parent_classifications.inject({}) { |h, c| h[c.annotation] ||= []; h[c.annotation] << {created: c.created_at, user_id: c.user_id, duration: c.finished_at.to_time - c.started_at.to_time, user_id: c.user_id.to_s }; h }
    grouped = grouped.inject([]) { |a,(annotation,count)| a << {data: annotation, votes: count, confidence: count.to_f / num_votes, instances: classifications_by_annotation[annotation] }; a }
    grouped = grouped.sort_by { |a| - a[:confidence] }
    grouped
  end

end
