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

    return nil if object.nil?

    if serialization_options[:subject_request_scope] == "active_root"
      if random
        object.subjects.active_root.where(workflow_id: workflow_id).random(limit: limit)
      else
        object.subjects.active_root.where(workflow_id: workflow_id).limit(limit)
      end
    elsif serialization_options[:subject_request_scope] == "active"
      if random
        object.subjects.active.where(workflow_id: workflow_id).random(limit: limit)
      else
        object.subjects.active.where(workflow_id: workflow_id).limit(limit)
      end
    end
  end

end
