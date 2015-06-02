class Workflow
  include Mongoid::Document

  field    :name,                                            type: String
  #TODO: can we delete :key field? --AMS
  field    :key, 				                                     type: String
  field    :label,                                           type: String
  # field    :tasks, 			      	                             type: Hash
  field    :first_task,                                      type: String
  field    :retire_limit, 		                               type: Integer,   default: 10
  field    :subject_fetch_limit,                             type: Integer,   default: 10
  field    :generates_subjects,                              type: Boolean,   default: true
  field    :generates_subjects_after,                        type: Integer,   default: 0
  field    :generates_subjects,                              type: Boolean,   default: false
  field    :generates_subjects_for,                          type: String,    default: ""
  field    :generates_subjects_max,                          type: Integer
  field    :generates_subjects_method,                       type: String,    default: 'one-per-classification'
  field    :active_subjects,                                 type: Integer,   default: 0

  has_many     :subjects
  has_many     :classifications
  belongs_to   :project

  embeds_many :tasks, class_name: 'WorkflowTask'

  def subject_has_enough_classifications(subject)
    subject.classification_count >= self.generates_subjects_after
  end


  def create_secondary_subjects(classification)   
    return unless self.generates_subjects || true
    # return unless subject_has_enough_classifications(classification.subject)
    workflow_for_new_subject_id = nil
    if ! classification.subject.workflow.next_workflow.nil?
      workflow_for_new_subject_id = classification.subject.workflow.next_workflow.id
    end
    # puts "gen secondary from: #{classification.inspect}"

    task = task_by_key classification.task_key

    subject_type = task.generates_subject_type

    # TODO this is temporary:
    # If tool specified in annotation, we need to look deeper:
    if subject_type.nil?
      subject_type = classification.annotation['generates_subject_type']
    end

    # puts "task: #{task.inspect}"
    # puts "generating? #{task.generates_subjects}: #{subject_type}"

    if task.generates_subjects

      # If this is the mark workflow, create region:
      if classification.workflow.name == 'mark'
        region = classification.annotation.inject({}) do |h, (k,v)|
          h[k] = v if ['toolName'].include? k
          h[k] = v.to_f if ['x','y','width','height','yUpper','yLower'].include? k
          h
        end
      else
        # Otherwise, it's a later workflow and we should copy `region` from parent subject
        region = classification.subject.region

      end

      data = classification.annotation.except(:key, :tool, :generates_subject_type)
      # puts "saving data: #{data.inspect}"

      # classification.child_subject = Subject.create(

      # puts "ClassificationsController: workflow_id: #{workflow_for_new_subject_id}, subject_id: #{classification.subject.id})"

      classification.child_subject = Subject.find_or_initialize_by(workflow_id: workflow_for_new_subject_id, parent_subject_id: classification.subject.id, type: subject_type)

           # annotation["tool_task_description"]["generates_subject_type"]
      if classification.child_subject.persisted?
        # puts "ClassificationsController: persisted.. #{classification.workflow.generates_subjects_method}"
        if classification.workflow.generates_subjects_method == 'collect-unique'
          classification.child_subject.data['values'].push data unless classification.child_subject.data['values'].include?(data)
          # puts "ClassificationsController: pushing data: #{classification.child_subject.data}"
          classification.child_subject.save
        end

      else
        if classification.workflow.generates_subjects_method == 'collect-unique'
          data = {'values' => [data]}
        end
        # puts "ClassificationsController: not persisted; svaing data: #{data}"
        classification.child_subject.update_attributes({
          subject_set: classification.subject.subject_set,
          location: {
            standard: classification.subject.location[:standard]
          },
          data: data,
          region: region,
          width: classification.subject.width,
          height: classification.subject.height
        })
      end
      # puts child_subject
      # classification.child_subject = child_subject
      classification.save
      classification.child_subject
    end
  end

  def find_tools_from_subject_type(subject_type)
    task_keys = self.tasks.keys
    task_keys.each do |task|

      if self.tasks[task]["tools"].present?
        array_of_tool_boxes = self.tasks[task]["tools"]
        array_of_tool_boxes.each do |tool_box|
          return tool_box if tool_box["generates_subject_type"] == subject_type
          # example tool_box:{"type"=> "textRowTool", "label"=> "Question", "color"=> "green", "generates_subject_type"=> "att_textRowTool_question" }

        end

      end
    end
  end

  def next_workflow
    if ! generates_subjects_for.nil? 
      Workflow.find_by(name: generates_subjects_for)
    end
  end

  def create_follow_up_subjects(classification)
    return unless self.generates_subjects
    return unless subject_has_enough_classifications(classification.subject)
    create_secondary_subjects(classification)
  end

  def task_by_key(key)
    # puts "tasks: #{tasks.inspect}"
    tasks.where(key: key).first
  end
end
