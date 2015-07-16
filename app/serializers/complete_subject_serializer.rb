class CompleteSubjectSerializer < ActiveModel::MongoidSerializer

  attributes :id, :location, :region, :width, :height, :meta_data
  attributes :data, :task

  def task
    task = object.parent_workflow_task
    {
      instruction: task.instruction,
      help: task.help,
      tool: task.tool,
      tool_config: task.tool_config
    }
  end

  def id
    object._id.to_s
  end

end
