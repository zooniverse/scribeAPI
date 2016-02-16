class FinalSubjectSetSerializer < ActiveModel::MongoidSerializer
  
  attributes :id, :meta_data, :type, :search_terms_by_field

  has_many :subjects
  has_one :export_document

  def id
    object.id.to_s
  end

  def type
    'final_subject_set'
  end
end
