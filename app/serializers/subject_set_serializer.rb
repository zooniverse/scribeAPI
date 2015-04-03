class SubjectSetSerializer < ActiveModel::MongoidSerializer
  attributes :id, :name, :thumbnail, :meta_data

  has_many :subjects

  def id
    object._id.to_s
  end


end
