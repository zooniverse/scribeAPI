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
    m = { 
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page,
      total_pages: object.total_pages,
      total: object.count
    } if object.respond_to? :current_page
    m = m.merge(serialization_options[:meta]) if ! serialization_options[:meta].nil?
    m
  end

  def links
    m = {}
    if serialization_options[:base_url]
      base_url,query = serialization_options[:base_url].split '?'
      query = Rack::Utils.parse_nested_query query
      m[:next_page_uri] = "#{base_url}?#{query.merge({"page" => object.next_page}).to_query}" if object.next_page
      m[:prev_page_uri] = "#{base_url}?#{query.merge({"page" => object.prev_page}).to_query}" if object.prev_page
    end
    m.merge! serialization_options[:links] if serialization_options[:links]
    m
  end
end
