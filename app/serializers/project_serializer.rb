class ProjectSerializer < ActiveModel::MongoidSerializer
  attributes :id, :title, :short_title, :summary, :home_page_content, :organizations , :team, :pages, :menus, :partials, :logo, :background, :workflows, :forum, :tutorial, :feedback_form_url, :metadata_search, :terms_map, :blog_url, :discuss_url, :privacy_policy, :downloadable_data
  attributes :classification_count
  has_many :workflows

  # delegate :current_or_guest_user, to: :scope

  def classification_count
    Classification.count
  end

  def id
    object._id.to_s
  end

end
