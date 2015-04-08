class ProjectSerializer < ActiveModel::MongoidSerializer
  attributes :id, :title, :summary, :home_page_content, :organizations , :team, :pages, :background, :workflows, :forum
  has_many :workflows

  def id
    object._id.to_s
  end


end
