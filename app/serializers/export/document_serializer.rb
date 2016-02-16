class Export::DocumentSerializer < ActiveModel::MongoidSerializer
  attributes :name

  has_many :export_fields
end
