class SubjectSetSerializer < ActiveModel::MongoidSerializer

  attributes :id, :name, :thumbnail, :meta_data, :subjects, :state, :counts, :group_id
  has_many :subjects

  def id
    object._id.to_s
  end

  def subjects
    workflow_id = serialization_options[:workflow_id]
    limit = serialization_options[:limit].to_i
    random = serialization_options[:random]

    if random
      object.subjects.where(workflow_id: workflow_id).random(limit: limit)
    else
      object.subjects.where(workflow_id: workflow_id).limit(limit)
    end
  end


end
