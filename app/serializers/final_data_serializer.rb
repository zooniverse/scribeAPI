class FinalDataSerializer < ActiveModel::MongoidSerializer
  attributes :data, :links, :meta

  root false

  def data
    options = serialization_options.merge({root: false})
    object.map { |s| FinalDataSubjectSetSerializer.new(s, root: false) }
  end

  def meta
    { 
    }
  end

  def links
    {}
  end
end
