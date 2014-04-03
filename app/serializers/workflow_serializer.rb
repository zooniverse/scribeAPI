class WorkflowSerializer < ActiveModel::Serializer
  attributes :id, :name, :tasks, :retire 

  def id
    object._id.to_s
  end


end
