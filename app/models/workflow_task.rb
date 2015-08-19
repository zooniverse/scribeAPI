class WorkflowTask
  include Mongoid::Document

  field    :key,                                     type: String
  field    :tool,                                    type: String
  field    :instruction,                             type: String
  field    :help,                                    type: String
  field    :generates_subject_type,                  type: String
  field    :tool_config,                             type: Hash
  field    :next_task,                               type: String
  field    :help,                                    type: Hash

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
    if config
      type = config[:generates_subject_type]
    end

    type
  end

  # If classification has subToolIndex and this task specifies a tools array, determine the tool-specific generates_subject_type
  def sub_tool_config(classification=nil)
    if ! classification.nil? && ! (subToolIndex = classification.annotation["subToolIndex"]).nil?
      find_tool_box(subToolIndex.to_i)

    elsif ! classification.nil? && ! (option_value = classification.annotation["value"]).nil? && ! (opt = tool_config["options"].select { |c| c['value'].to_s == option_value }).empty?
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

  def generates_subjects?(classification = nil)
    # subtool_generates_subjects = ! (c = tool_config).nil? && ! (c = c['options']).nil? && ! c.select { |c| ! c['generates_subject_type'].nil? && (classification.nil? || classification.annotation['value'] == c['value'] }.empty?

    # If this is a pick-one- style task, some of its options may generate subjects
    # Create hash mapping option_values to generates_subject_type
    subtool_generates_subjects = nil
    if ! classification.nil? && ! classification.annotation['value'].nil?
      subtool_configs = ! (c = tool_config).nil? && ! (c = c['options']).nil? ? c.inject({}) { |h, _c| h[_c['value']] = _c['generates_subject_type']; h } : {}
      # This task generates subjects for this classification if the classification 
      # targets a tool option that has a non-nil generates_subject_type:
      subtool_generates_subjects = subtool_configs[classification.annotation['value'].to_sym]
    end

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
