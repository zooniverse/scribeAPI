class SubjectGenerationMethod

  def self.by_name(name)
    methods = {
      'one-per-classification'    => SubjectGenerationMethods::OnePerClassification,
      'collect-unique'            => SubjectGenerationMethods::CollectUnique,
      'most-popular'              => SubjectGenerationMethods::MostPopular
    }

    raise "Invalid subject generation method" if methods[name].nil?

    methods[name].new
  end

  def process_classification(classification)
    raise "Invalid subject generation method: Attempted to use abstract SubjectGenerationMethod#process_classification"
  end

  # This is the `super` implementation, which generates the base subject, which the more specific generation methods adapt
  def subject_attributes_from_classification(classification)

    workflow = classification.subject.workflow

    workflow_for_new_subject = nil
    if ! workflow.next_workflow.nil?
      workflow_for_new_subject = classification.subject.workflow.next_workflow
    end

    task = workflow.task_by_key classification.task_key
    subject_type = task.subject_type classification

    # Now that we know what the subject_type will be, let's make sure that type corresponds with a task key
    # in the next workflow (i.e. a Transcribe key). If it does NOT, do not associate this generated subject
    # with the workflow (lest the subject show up in a workflow with no corresponding task)
    if ! workflow_for_new_subject.nil? && workflow_for_new_subject.task_by_key(subject_type).nil?
      workflow_for_new_subject = nil
    end

    # If this is the mark workflow, create region:
    if classification.workflow.name == 'mark'
      region = build_mark_region(classification)
    else
      # Otherwise, it's a later workflow and we should copy `region` from parent subject
      region = classification.subject.region
    end
    # If marking tool has a label, save it:
    if (label = task.tool_label(classification))
      region[:label] = label
    end
    # If region.color not passed from client, derive it from workflow_task tool config:
    if ! region[:color] && task.sub_tool_config(classification)
      region[:color] = task.sub_tool_config(classification)[:color]
    end

    {
      parent_subject: classification.subject,
      created_by_user_id: classification.user.id, # Note this doesn't work if mult users' classifications contribute to generating a single subject
      subject_set: classification.subject.subject_set,
      group_id: classification.subject.subject_set.group_id,
      workflow: workflow_for_new_subject,
      type: subject_type,
      location: {
        standard: classification.subject.location[:standard]
      },
      region: region.empty? ? nil : region,
      width: classification.subject.width,
      height: classification.subject.height
    }
  end

  def build_mark_region(classification)
    region = classification.annotation.inject({}) do |h, (k,v)|
      h[k] = v if ['toolName','color'].include? k
      h[k] = v.to_f if ['x','y','width','height','yUpper','yLower'].include? k
      h
    end
  end
end
