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

  def subject_attributes_from_classification(classification)

    workflow = classification.subject.workflow

    workflow_for_new_subject = nil
    if ! workflow.next_workflow.nil?
      workflow_for_new_subject = classification.subject.workflow.next_workflow
    end

    task = workflow.task_by_key classification.task_key
    subject_type = task.subject_type classification

    # If this is the mark workflow, create region:
    if classification.workflow.name == 'mark'
      region = build_mark_region(classification)
    else
      # Otherwise, it's a later workflow and we should copy `region` from parent subject
      region = classification.subject.region
    end
    region[:label] = task.tool_label classification

    {
      parent_subject: classification.subject,
      created_by_user_id: classification.user.id,
      subject_set: classification.subject.subject_set,
      workflow: workflow_for_new_subject,
      type: subject_type,
      location: {
        standard: classification.subject.location[:standard]
      },
      region: region,
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
