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

  # Returns generates_subject_type for transcribe/verify tasks;
  # In mark tasks, the generates_subject_type depends on the selected tool, so we need to check the classification's subToolIndex:
  def subject_type(classification=nil)
    type = generates_subject_type
    # If classification has subToolIndex and this task specifies a tools array, determine the tool-specific generates_subject_type
    if ! classification.nil? && ! (subToolIndex = classification.annotation["subToolIndex"]).nil?
      type = find_tool_box(subToolIndex.to_i)[:generates_subject_type]
    end

    type
  end

  # Get tool_config hash for this task
  # If given field name matches a sub-tool, returns that tools config
  def tool_config_for_field(field_name)
    # If field name matches an entry in tool_config.tools, return the nested tool-config
    puts "::::#{field_name}", tool_config['tools'].inspect
    if ! tool_config.nil? && ! tool_config['tools'].nil? && tool_config['tools'].is_a?(Hash) && ! tool_config['tools'][field_name].nil?
      tool_config['tools'][field_name]["tool_config"]
    else
      tool_config
    end
  end

  def generates_subjects?
    subtool_generates_subjects = ! (c = tool_config).nil? && ! (c = c['tools']).nil? && ! c.select { |c| ! c['generates_subject_type'].nil? }.empty?
    ! generates_subject_type.nil? || subtool_generates_subjects || ! has_next_task?
  end

  def has_next_task?
    suboption_has_next_task = ! tool_config.nil? && ! (c = tool_config['options']).nil? && ! c.select { |k,h| puts "inspecting #{h.inspect}"; ! h['next_task'].nil? }.empty?
    ! next_task.nil? || suboption_has_next_task
  end


  private

  def find_tool_box(subToolIndex)
    tool_config["tools"][subToolIndex] if tool_config["tools"]
  end

end
