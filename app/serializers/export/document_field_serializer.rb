class Export::DocumentFieldSerializer < ActiveModel::MongoidSerializer
  attributes :name, :value, :original_value, :assertion_ids

  def assertion_ids
    object.assertion_ids.map { |oid| oid.to_s } unless object.assertion_ids.blank?
  end

end
