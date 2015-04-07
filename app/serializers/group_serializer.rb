class GroupSerializer < ActiveModel::MongoidSerializer
  attributes :id, :name, :description, :key, :cover_image_url, :external_url, :meta_data, :stats
  has_many :subject_sets
  def id
    object._id.to_s
  end


end
