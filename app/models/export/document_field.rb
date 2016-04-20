class Export::DocumentField
  include Mongoid::Document

  embedded_in :export_document

  field :name,                    type: String
  field :value
  field :original_value
  field :assertion_ids,           type: Array

  has_one :spec, class_name: 'Export::Spec::DocumentField'
  embeds_many :sub_fields, class_name: 'Export::DocumentField'

  def data
    if sub_fields.empty?
      value
    else
      sub_fields.inject({}) do |h, f|
        h[f.name] = f.data
        h
      end
    end
  end

  def to_s(indent=0)
    if ! sub_fields.empty?
      "#{name}:\n" + ("  " * indent) + sub_fields.map { |f| f.to_s(indent+1) }.join("\n" +  ("  " * indent))

    else
      "#{name}: #{value} (orig \"#{original_value}\")" #  [assertion(s) #{assertion_ids}]"
    end
  end
end
