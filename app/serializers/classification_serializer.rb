class ClassificationSerializer < ActiveModel::MongoidSerializer
  attributes :id, :workflow_id, :subject_id, :subject_set_id, :location, :annotations, :triggered_followup_subject_ids, :child_subject
  
  has_one :workflow
  has_one :user
  has_one :subject
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

  def subject_set_id
    object.subject_set_id.to_s
  end

  def child_subject_id
    object.child_subject_id.to_s
  end

end
