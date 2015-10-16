module SubjectGenerationMethods

  class CollectUnique < SubjectGenerationMethod

    def process_classification(classification)

      atts = subject_attributes_from_classification(classification)
      atts[:status] = 'inactive'

      classification.child_subject = Subject.find_or_initialize_by(workflow: atts[:workflow], parent_subject: atts[:parent_subject], type: atts[:type])
      classification.save

      ann = classification.annotation.except(:key, :tool, :generates_subject_type)

      # Collect unique annotations into data hash
      if classification.child_subject.persisted?

        values = classification.child_subject.data['values'].nil? ? [] : classification.child_subject.data['values']
        values.push ann unless values.include? ann

        atts[:data] = {'values' => values}

      else
        atts[:data] = {'values' => [ann]}
      end
      atts[:data][:task_prompt] = classification.workflow_task.instruction

      # Don't update attributes already saved/initialized in subject:
      atts = atts.except(:workflow, :parent_subject, :type)

      num_parent_classifications = classification.child_subject.parent_classifications.count

      # If subject has enough parent classifications, activate it:
      # puts "considering activating.... if #{num_parent_classifications} >= #{classification.workflow.generates_subjects_after}"
      if num_parent_classifications >= classification.workflow.generates_subjects_after
        puts "Activating generated subject because now has #{num_parent_classifications} parent classifications"

        # Get number of distinct classifications:
        num_vals = classification.child_subject.data['values'].nil? ? -1 : classification.child_subject.data['values'].size

        # Get subject-generation method type (presumably for Verify workflow) (which is likely 'most-popular')
        verify_method = classification.child_subject.workflow.generates_subjects_method

        if num_vals == 1 && verify_method == 'most-popular'
          puts "Auto upgrading verify subject to complete because only one val: #{classification.child_subject.data}"
          atts[:status] = 'complete'

        else
          classification.child_subject.activate! # atts[:status] = 'active'
          atts.delete :status
        end
      end

      # puts "Saving atts to classification: #{atts.inspect}"
      classification.child_subject.update_attributes atts

      classification.child_subject
    end

  end

end
