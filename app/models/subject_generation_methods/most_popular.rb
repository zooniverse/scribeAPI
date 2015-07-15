module SubjectGenerationMethods

  class MostPopular < SubjectGenerationMethod

    def process_classification(classification)

      atts = subject_attributes_from_classification classification
      atts[:status] = 'inactive'

      classification.child_subject = Subject.find_or_initialize_by(workflow: atts[:workflow], parent_subject: atts[:parent_subject], type: atts[:type])
      classification.save

      ann = classification.annotation

      most_popular = classification.child_subject.calculate_most_popular_parent_classification
      atts[:data] = most_popular[:ann]

      num_parent_classifications = classification.child_subject.parent_classifications.count
      has_min_classifications = num_parent_classifications >= classification.workflow.generates_subjects_after
      has_min_agreement = most_popular[:percentage] >= classification.workflow.generates_subjects_agreement

      if has_min_classifications

        if has_min_agreement
          atts[:status] = 'complete'

        # No agreement yet. Enough to mark contentious?
        elsif num_parent_classifications > classification.workflow.generates_subjects_max
          atts[:status] = 'contentious'
        end
      end

      # Don't update attributes already saved/initialized in subject:
      atts = atts.except(:workflow, :parent_subject, :type)

      classification.child_subject.update_attributes atts

      classification.child_subject
    end

  end

end
