class SubjectSetSerializer < ActiveModel::MongoidSerializer


  attributes :id, :selected_subject_id, :type, :name, :thumbnail, :meta_data, :subjects, :state, :counts, :group_id, :subjects_pagination_info

  # PB: Can't seem to get serialization_options set correctly when instantiated by
  # another serializer unless I declare constructor thusly:
  def initialize(object, options={})
    @_serialization_options = options
    super object
  end

  def type
    "subject_sets"
  end

  def root
    @_serialization_options[:root].nil? ? :subject_set : @_serialization_options[:root]
  end

  def group_id
    object.group_id.to_s
  end

  def id
    object._id.to_s
  end

  def selected_subject_id
    serialization_options[:subject_id] if serialization_options[:subject_id]
  end

  def subjects_pagination_info
    {
      current_page: _subjects.current_page,
      next_page: _subjects.next_page,
      prev_page: _subjects.prev_page,
      total_pages: _subjects.total_pages
    }
  end

  def subjects
    _subjects.map { |s| SubjectSerializer.new s, root: false }
  end

  def _subjects
    @_subjects ||= (
      # TODO serialization_options seems to be nil when this serializer is invoked from another serializer.. baaaaaaaah
      options = serialization_options.nil? ? serialization_options : @_serialization_options

      workflow_id = options[:workflow_id] # I think we need to pull workflow_id from serialization_options, subject_sets don't belong to workflow.
      subjects_limit = options[:subjects_limit] || 100
      subjects_page = options[:subjects_page] || 1
      # return nil if object.nil?

      subjs = object.subjects.root.page(subjects_page).limit(subjects_limit)
    )
  end

end
