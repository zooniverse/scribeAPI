class ProjectSerializer < ActiveModel::MongoidSerializer
  attributes :id, :title ,:summary ,:description, :home_page_content ,:organizations ,:scientists ,:developers, :workflows, :background, :pages
  has_many :workflows

  def id
    object._id.to_s
  end



end
