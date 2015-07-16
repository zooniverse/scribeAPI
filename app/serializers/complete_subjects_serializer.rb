class CompleteSubjectsSerializer < ActiveModel::MongoidSerializer
  attributes :data, :links, :meta

  root false

  def data
    options = serialization_options.merge({root: false})
    object.map { |s| CompleteSubjectSerializer.new(s, root: false) }
  end

  def meta
    { 
    }
  end

  def links
    {}
  end
end
