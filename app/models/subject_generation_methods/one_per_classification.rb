module SubjectGenerationMethods

  class OnePerClassification < SubjectGenerationMethod

    def process_classification(classification)

      atts = subject_attributes_from_classification(classification)

      atts[:data] = classification.annotation.except(:key, :tool, :generates_subject_type)

      classification.child_subject = Subject.create atts # (workflow_id: workflow_for_new_subject_id, parent_subject_id: classification.subject.id, type: subject_type)

      classification.save
      classification.child_subject
    end

  end

end
