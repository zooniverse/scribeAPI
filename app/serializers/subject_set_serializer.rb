class SubjectSetSerializer < ActiveModel::MongoidSerializer

  attributes :id, :name, :thumbnail, :meta_data, :subjects, :state, :counts, :group_id
  has_many :subjects
  
  def id
    object._id.to_s
  end

  def subjects
    workflow_id = serialization_options[:workflow_id]
    object.subjects.where(workflow_id: workflow_id)
  end


end
