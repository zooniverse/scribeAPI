class WorkflowSerializer < ActiveModel::MongoidSerializer
  attributes :id, :name, :label, :tasks, :retire_limit, :subject_fetch_limit, :first_task, :active_subjects

  def id
    object._id.to_s
  end

end
