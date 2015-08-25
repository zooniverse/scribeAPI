class FinalDataSubjectSetSerializer < ActiveModel::MongoidSerializer

  attributes :id
  attributes :name
  attributes :meta_data
  attributes :classification_count
  attributes :subjects

  def subjects
    object.subjects.root.map { |s| FinalDataSubjectSerializer.new(s, root: false) }
  end

  def id
    object._id.to_s
  end

end
