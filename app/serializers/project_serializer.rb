class ProjectSerializer < ActiveModel::MongoidSerializer
  attributes :id, :title, :short_title, :summary, :home_page_content, :organizations , :team, :pages, :background, :workflows, :forum, :feedback_form_url, :metadata_search
  has_many :workflows

  def id
    object._id.to_s
  end


end
