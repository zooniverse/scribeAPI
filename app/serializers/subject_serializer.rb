class SubjectSerializer < ActiveModel::MongoidSerializer
  attributes :id, :parent_subject_id, :workflow_id, :name, :location, :classification_count, :child_subjects, :meta_data, :user_favourite
  delegate :current_user, to: :scope

  def id
    object._id.to_s
  end

  def user_favourite
    (scope and scope.has_favourite?(object))
  end

  def child_subjects
    Subject.where(:parent_id => object.id)
  end

end
