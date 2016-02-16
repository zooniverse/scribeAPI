class Export::Spec::DocumentFieldSerializer < ActiveModel::MongoidSerializer
  attributes :format, :name

  def format
    object.sub_fields.blank? && object.format.nil? ? 'string' : object.format
  end
end
