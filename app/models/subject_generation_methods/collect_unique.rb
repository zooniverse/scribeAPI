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
      if num_parent_classifications >= classification.workflow.generates_subjects_after

        # Get number of distinct classifications:
        # num_vals = classification.child_subject.data['values'].nil? ? -1 : classification.child_subject.data['values'].size
        num_vals = atts[:data]['values'].size

        # Where will this generated subject appear, if anywhere?
        next_workflow = classification.child_subject.workflow

        # If there is no next workflow, this subject is done. Presumably the retire_limit caused the parent subject to be retired as well.
        if next_workflow.nil? 
          atts[:status] = 'complete'

        # There is a next workfllow (probably Verify)
        else
          # Get subject-generation method type (presumably for Verify workflow) (which is likely 'most-popular')
          verify_method = next_workflow.generates_subjects_method

          # If next workflow's generation method is most-popular and everyone transcribed the same thing, auto upgrade to 'complete':
          # (but only if num_parent_classifications  > 1)
          if num_vals == 1 && verify_method == 'most-popular' && num_parent_classifications > 1 
            atts[:status] = 'complete'

          # .. Otherwise, activate the generated subject into the next workflow:
          else
            atts[:status] = 'active'
          end
        end
      end

      # PB: At writing, only verify uses collect-unique. It's important that
      # subjects generated from transcribe not be classifyable (i.e. voted upon)
      # by any user submitting a transcription. We should probably support a 
      # thus generated are not classifyable by classification authors.
      atts[:creating_user_ids] = classification.child_subject.creating_user_ids
      atts[:creating_user_ids] ||= []
      classification.child_subject.creating_user_ids.push classification.user_id

      classification.child_subject.update_attributes atts

      # Now that child subj is saved (with a parent subject_set) Fire activate hooks if activating:
      classification.child_subject.activate! if atts[:status] == 'active'

      classification.child_subject
    end

  end

end
