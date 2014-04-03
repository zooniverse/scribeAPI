class ProjectSerializer < ActiveModel::MongoidSerializer
  attributes :id, :title ,:summary ,:description ,:organizations ,:scientists ,:developers, :workflows
  has_many :workflows

  def id
    object._id.to_s
  end



end
