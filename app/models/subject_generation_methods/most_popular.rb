module SubjectGenerationMethods

  class MostPopular < SubjectGenerationMethod

    def process_classification(classification)

      atts = subject_attributes_from_classification(classification)
      atts[:status] = 'inactive'

      classification.child_subject = Subject.find_or_initialize_by(workflow: atts[:workflow], parent_subject: atts[:parent_subject], type: atts[:type])
      classification.save

      ann = classification.annotation

      # Get most popular annotation in all classifications that are siblings to
      # this classification as well as classifications made upone this classification's
      # generated subject (effectively combine transcriptions and verify votes)
      weights = classification.subject.parent_and_descendent_classifications_grouped
      most_popular = weights.first
      atts[:data] = most_popular[:ann]

      num_parent_classifications = classification.child_subject.parent_classifications.count
      has_min_classifications = num_parent_classifications >= classification.workflow.generates_subjects_after
      has_min_agreement = most_popular[:percentage] >= classification.workflow.generates_subjects_agreement

      if has_min_classifications

        # Determine whether or not to deactivate parent subject due to generated subject being complete or contentious
        deactivate_parent = false

        if has_min_agreement
          atts[:status] = 'complete'
          deactivate_parent = true

        # No agreement yet. Enough to mark contentious?
        elsif num_parent_classifications > classification.workflow.generates_subjects_max
          atts[:status] = 'contentious'
          deactivate_parent = true
        end

        # Child subj is complete (or contentious) so retire parent:
        classification.subject.retire! if deactivate_parent
      end

      # Don't update attributes already saved/initialized in subject:
      atts = atts.except(:workflow, :parent_subject, :type)

      classification.child_subject.update_attributes atts

      classification.child_subject
    end

  end

end
