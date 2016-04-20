class ProjectSerializer < ActiveModel::MongoidSerializer
  attributes :id, :title, :short_title, :summary, :home_page_content, :organizations , :team, :pages, :page_navs, :menus, :partials, :logo, :background, :workflows, :forum, :tutorial, :feedback_form_url, :metadata_search, :terms_map, :blog_url, :discuss_url, :privacy_policy, :downloadable_data, :latest_export
  attributes :classification_count, :root_subjects_count
  has_many :workflows

  has_many :export_document_specs

  def latest_export
    FinalDataExportSerializer.new FinalDataExport.most_recent.first, root: false
  end

  def classification_count
    # TODO: This should be scoped to project, but Classification#project_id doesn't exist
    Classification.count
  end

  def root_subjects_count
    # TODO: This too should be scoped to project, but Subject#project_id doesn't exist...
    Subject.root.count
  end

  def id
    object._id.to_s
  end

end
