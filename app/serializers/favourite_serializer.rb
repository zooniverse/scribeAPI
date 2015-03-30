class FavouriteSerializer < ActiveModel::MongoidSerializer
  attributes :id
  has_one :subject

  def id
    object._id.to_s
  end

end
