class GroupSerializer < ActiveModel::MongoidSerializer
  attributes :id, :type, :name, :description, :key, :cover_image_url, :external_url, :meta_data, :stats

  def type
    "groups"
  end

  def id
    object._id.to_s
  end

end
