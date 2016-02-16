class Export::Spec::DocumentField
  include Mongoid::Document

  field :name,                    type: String
  field :select,                  type: String
  field :format                   # string, monetary, address, {}
  field :format_options,          type: Hash # e.g. "format_options": {"range": [1850,1950]}
  field :repeats,                 type: Boolean
  embeds_many :sub_fields, class_name: 'Export::Spec::DocumentField'
  embedded_in :export_document_spec, class_name: 'Export::Spec::Document'
  embedded_in :export_document_spec_field, class_name: 'Export::Spec::DocumentField'

  def to_s
    name + (select.nil? ? '' : " (select: \"#{select}\")")
  end

  def self.from_hash(h, doc_spec, parent_field=nil)
    inst = self.new export_document_spec: doc_spec, name: h['name'], select: h['select'], format: h['format'], format_options: h['format_options'], repeats: h['repeats']
    if ! h['sub_fields'].blank? 
      h['sub_fields'].each do |sub_h|
        inst.sub_fields << from_hash(sub_h, nil, inst)
      end
    end
    inst
  end
end
