class SubjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :location, :classification_count, :child_subjects, :meta_data

  def id
    object._id.to_s
  end

  def child_subjects
    Subject.where(:parent_id => object.id)
  end

end
