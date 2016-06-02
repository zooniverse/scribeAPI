class Export::Spec::Document
  include Mongoid::Document

  field :name,                    type: String

  embeds_many :spec_fields, class_name: 'Export::Spec::DocumentField'
  embedded_in :project

  def self.from_hash(h, project)
    inst = self.new project: project, name: h['name']
    inst.spec_fields = h['spec_fields'].map do |h|
      Export::Spec::DocumentField.from_hash h, inst
    end
    inst
  end

  def field_by_name(name)
    spec_fields.each do |f|
      return f if f.name == name
      if f.sub_fields
        fs = f.sub_fields.select { |_f| _f.name == name }
        return fs.first if ! fs.empty?
      end
    end
    nil
  end
end
