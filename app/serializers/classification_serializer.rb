class ClassificationSerializer < ActiveModel::MongoidSerializer
  attributes :id, :workflow_id, :subject_id, :subject_set_id, :location, :annotations, :triggered_followup_subject_ids, :child_subject_id, :child_subject
  
  belongs_to :workflow
  belongs_to :user
  belongs_to :subject

  def id
    object._id.to_s
  end

  def child_subject
    Subject.find(child_subject_id)
  end

end
