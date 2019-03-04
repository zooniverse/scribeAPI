class ProjectSerializer < ActiveModel::MongoidSerializer
  attributes :id, :title, :short_title, :summary, :home_page_content, :organizations , :team, :pages, :menus, :partials, :logo, :background, :workflows, :forum, :tutorial, :feedback_form_url, :metadata_search, :terms_map, :blog_url, :discuss_url, :privacy_policy, :analytics, :show_labels
  has_many :workflows

  # delegate :current_or_guest_user, to: :scope

  def id
    object._id.to_s
  end

=begin
  def current_user_tutorial
    user = scope.nil? ? nil : current_or_guest_user
    unless user == nil
      user.tutorial_complete
    end
  end
=end

end
