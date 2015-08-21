class ProjectSerializer < ActiveModel::MongoidSerializer
  attributes :id, :title, :short_title, :summary, :home_page_content, :organizations , :team, :pages, :logo, :background, :workflows, :forum, :tutorial, :feedback_form_url, :metadata_search, :current_user_tutorial
  has_many :workflows

  delegate :current_or_guest_user, to: :scope

  def id
    object._id.to_s
  end

  def current_user_tutorial
    user = scope.nil? ? nil : current_or_guest_user
    unless user == nil
      user.tutorial_complete
    end
  end

end
