class SubjectSetResultSerializer < ActiveModel::MongoidSerializer
  attributes :data, :links, :meta

  root false

  def data
    options = serialization_options.merge({root: false, scope: scope})
    object.map { |s| SubjectSetSerializer.new(s, options) }
  end

  def meta
    { 
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page,
      total_pages: object.total_pages,
      total: object.count
    }
  end

  def links
    serialization_options[:links]
  end
end
