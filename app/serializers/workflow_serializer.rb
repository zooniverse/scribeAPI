class WorkflowSerializer < ActiveModel::Serializer
  attributes :id, :label , :key , :tasks, :retire_limit, :first_task

  def id
    object._id.to_s
  end

end
