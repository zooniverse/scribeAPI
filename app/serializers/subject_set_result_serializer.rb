class SubjectSetResultSerializer < ActiveModel::MongoidSerializer
  attributes :data, :links, :meta

  root false

  # This serializes both single objects and arrays of objects, so data should output either a hash or an array respectively:
  def data
    options = serialization_options.merge({root: false, scope: scope})
    if object.respond_to? :each
      object.map { |s| SubjectSetSerializer.new(s, options) }
    else
      SubjectSetSerializer.new(object, options)
    end
  end

  def meta
    { 
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page,
      total_pages: object.total_pages,
      total: object.count
    } if object.respond_to? :current_page
  end

  def links
    serialization_options[:links]
  end
end
