class UserSerializer < ActiveModel::MongoidSerializer
  attributes :id, :name, :recent_subjects

  def id
    object._id.to_s
  end

  def recent_subjects
    object.recents
  end

end
