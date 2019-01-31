class WorkflowTask
  include Mongoid::Document

  field    :key,                                     type: String
  field    :tool,                                    type: String
  field    :instruction,                             type: String, default: ''
  field    :help,                                    type: String
  field    :generates_subject_type,                  type: String
  field    :tool_config,                             type: Hash
  field    :next_task,                               type: String
  field    :help,                                    type: Hash
  field    :examples,                                type: Array
  field    :export_name,                             type: String

  embedded_in :workflow

  # Get the tool label that the user was responding to:
  def tool_label(classification=nil)
    config = sub_tool_config classification
    # If this task specifies an array of tools, look for tool-specific subject type:
    if config
      config[:label]
    end
  end

  # Returns generates_subject_type for transcribe/verify tasks;
  # In mark tasks, the generates_subject_type depends on the selected tool, so we need to check the classification's subToolIndex:
  def subject_type(classification=nil)
    type = generates_subject_type
    config = sub_tool_config classification
    # If this task specifies an array of tools, look for tool-specific subject type:
    if config && config[:generates_subject_type]
      type = config[:generates_subject_type]
    end

    type
  end

  # If classification has subToolIndex and this task specifies a tools array, determine the tool-specific generates_subject_type
  def sub_tool_config(classification=nil)
    if ! classification.nil? && ! (subToolIndex = classification.annotation["subToolIndex"]).nil?
      find_tool_box(subToolIndex.to_i)

    elsif ! classification.nil? && ! (option_value = classification.annotation["value"]).nil? && ! tool_config["options"].nil? && ! (opt = tool_config["options"].select { |c| c['value'].to_s == option_value }).empty?
      opt.first
    end
  end

  # Get tool_config hash for this task
  # If given field name matches a sub-tool, returns that tools config
  def tool_config_for_field(field_name)
    # If field name matches an entry in tool_config.tools, return the nested tool-config
    # if ! tool_config.nil? && ! tool_config['options'].nil? && tool_config['options'].is_a?(Hash) && ! tool_config['options'][field_name].nil?
    if ! tool_config.nil? && ! tool_config['options'].nil? && tool_config['options'].is_a?(Hash) && ! (pick_one_config = tool_config['options'].select { |c| c['value'] == field_name }).empty?
      # tool_config['options'][field_name]["tool_config"]
      pick_one_config.first["tool_config"]
    else
      tool_config
    end
  end

  # Given a classification, returns true if we should generate a subject from it
  # .. which is true if:
  #  1) there's a task-level generates_subject_type, OR:
  #  2) there's a subtool (i.e. pick-one-mark-one) with a marking tool specific generates_subject_type
  #  3) okay, really:any time we're at the end of a chain of tasks (but not the completion_assessment_task
  def generates_subjects?(classification = nil)

    # This would normally be unnecessary because completion_assessment_task tends
    # to be a dynamically added task not officially found in workflow json. That
    # fact should normally cause subject generation to fail because the task
    # can't be found. Just in case the admin has specified completion_assessment_task
    # explicitly in their workflow json, let's be sure to skip over it lest we 
    # create useless subjects with null `type`
    # return false if classification.task_key == 'completion_assessment_task'

    subtool_generates_subjects = subject_type classification
    ! generates_subject_type.nil? || subtool_generates_subjects || ! has_next_task?
  end

  def has_next_task?
    suboption_has_next_task = ! tool_config.nil? && ! (c = tool_config['options']).nil? && ! c.select { |c| ! c['next_task'].nil? }.empty?
    ! next_task.nil? || suboption_has_next_task
  end


  private

  def find_tool_box(subToolIndex)
    tool_config["options"][subToolIndex] if tool_config["options"]
  end

end
