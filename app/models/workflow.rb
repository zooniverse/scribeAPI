class Workflow
  include Mongoid::Document

  field    :name,                                            type: String
  #TODO: can we delete :key field?
  field    :key, 				                                     type: String
  field    :label,                                           type: String
  field    :tasks, 			      	                             type: Hash
  field    :first_task,                                      type: String
  field    :retire_limit, 		                               type: Integer,   default: 10
  field    :subject_fetch_limit,                             type: Integer,   default: 10
  field    :generates_new_subjects,                          type: Boolean,   default: false
  field    :generates_subjects_after,                        type: Integer,   default: 0
  field    :generates_subjects,                              type: Boolean,   default: false
  field    :generates_subjects_for,                          type: String,    default: ""
  field    :generates_subjects_max,                          type: Integer
  field    :active_subjects,                                 type: Integer,   default: 0


  has_many     :subjects
  has_many     :classifications
  belongs_to   :project


  def subject_has_enough_classifications(subject)
    subject.classification_count >= self.generates_subjects_after
  end


  def create_secondary_subjects(classification)
    return unless self.generates_new_subjects
    return unless subject_has_enough_classifications(classification.subject)
    workflow_for_new_subject = Workflow.find_by(name: classification.subject.workflow.generates_subjects_for)
    annotation = classification.annotation
      if classification.workflow.generates_new_subjects

        # If this is the mark workflow, create region:
        if classification.workflow.name == 'mark'
          region = annotation.inject({}) do |h, (k,v)|
            h[k] = v if ['toolName','x','y','width','height','yUpper','yLower'].include? k
            h
          end
        else
          # Otherwise, it's a later workflow and we should copy `region` from parent subject
          region = classification.subject.region
        end
      child_subject = Subject.create(
        workflow: workflow_for_new_subject ,
        subject_set: classification.subject.subject_set,
        parent_subject_id: classification.subject.id,
        tool_task_description: annotation["tool_task_description"],
        location: {
          standard: classification.subject.location[:standard]
        },
        # TODO: do we even need data now?

        data: annotation,
        region: region,
        type: annotation["tool_task_description"]["generates_subject_type"]
      )
      puts child_subject

      classification.child_subject = child_subject
      classification.save
      child_subject

      end

  end

  # not sure this is the best place for this method,
  # maybe it is better suited to classification or subject model?
  # def package_region_data(classification)
  #   binding.pry
  #   if classification.workflow.name == 'mark'
  #     region = classification.annotations.value.inject({}) do |h, (k,v)|
  #       h[k] = v if ['toolName','x','y','width','height','yUpper','yLower'].include? k
  #       h
  #     end
  #   else
  #     # Otherwise, it's a later workflow and we should copy `region` from parent subject
  #     region = classification.subject.region
  #   end
  #   region
  # end

end
