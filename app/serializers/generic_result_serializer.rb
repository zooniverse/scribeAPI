# Generic serializer for arrays of objects of arbitrary types
# Produces JSONAPI style results with pagination meta
class GenericResultSerializer < ActiveModel::MongoidSerializer
  attributes :data, :links, :meta

  root false

  # This serializes both single objects and arrays of objects, so data should output either a hash or an array respectively:
  def data
    options = serialization_options.merge({root: false, scope: scope})

    # Array of results?
    if object.respond_to? :each
      return [] if object.empty?

      # Determine what serializer to use based on class of first item:
      klass = object.first.class.to_s
      serializer_class = eval("#{klass}Serializer")
      object.map { |s| serializer_class.new(s, options) }

    else
      # Determine what serializer to use based on class of first item:
      klass = object.class.to_s
      serializer_class = eval("#{klass}Serializer")
      serializer_class.new(object, options)
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
