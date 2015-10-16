class ClassificationSerializer < ActiveModel::MongoidSerializer
  attributes :id, :workflow_id, :subject_id, :task_key, :annotation
  
  has_one :child_subject

  def id
    object._id.to_s
  end

  def workflow_id
    object.workflow_id.to_s
  end

  def subject_id
    object.subject_id.to_s
  end

  def child_subject_id
    object.child_subject_id.to_s
  end

end
