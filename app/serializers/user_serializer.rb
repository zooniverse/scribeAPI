class UserSerializer < ActiveModel::MongoidSerializer
  root false

  attributes :id, :guest, :name, :recent_subjects, :avatar, :tutorial_complete

  def id
    object._id.to_s
  end

  def recent_subjects
    object.recents
  end

end
