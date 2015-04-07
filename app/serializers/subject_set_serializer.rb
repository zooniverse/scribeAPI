class SubjectSetSerializer < ActiveModel::MongoidSerializer
  attributes :id, :name, :thumbnail, :meta_data, :group_id

  has_many :subjects

  def id
    object._id.to_s
  end


end
