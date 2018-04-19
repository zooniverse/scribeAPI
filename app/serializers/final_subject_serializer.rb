class FinalSubjectSerializer < ActiveModel::MongoidSerializer

  attributes :id, :type, :location, :status, :width, :height, :meta_data
  has_many :assertions

  # scope :by_keyword, -> (keyword) { where(: keyword) }

  def id
    object.id.to_s
  end
end
