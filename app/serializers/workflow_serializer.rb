class WorkflowSerializer < ActiveModel::MongoidSerializer
  attributes :id, :name, :label, :tasks, :retire_limit, :subject_fetch_limit, :first_task, :active_subjects, :generates_subjects_for

  def id
    object._id.to_s
  end

  def tasks
    object.tasks.inject({}) do |h, t|
      h[t.key] = WorkflowTaskSerializer.new(t, root: false)
      h
    end
  end

end
