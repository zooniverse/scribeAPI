class Export::Document
  include Mongoid::Document

  field :name,                   type: String

  belongs_to :spec, class_name: 'Export::Spec::Document'
  embeds_many :export_fields, class_name: 'Export::DocumentField'
  embedded_in :final_subject_set

  def self.from_set(set, specs)
    specs.each do |spec|
      return Export::DocumentBuilder.new(set, spec).export_document
    end
  end

  def data
    export_fields.inject({}) do |h, f|
      if h[f.name]
        h[f.name] = [h[f.name]] if ! h[f.name].is_a?(Array)
        h[f.name] << f.data
      else
        h[f.name] = f.data
      end
      h
    end
  end

  def to_s
    ret = []
    ret << "#{spec.name}"
    export_fields.each do |field|
      ret << "  #{field.to_s(2)}"
    end
    ret.join "\n"
  end
end
