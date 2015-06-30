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

    if random
      subjects = Kaminari.paginate_array(object.subjects.active_root.where(workflow_id: workflow_id).random(limit: limit)).page(serialization_options[:page])      
    else
      subjects = Kaminari.paginate_array(object.subjects.active_root.where(workflow_id: workflow_id).limit(limit)).page(serialization_options[:page])
    end
  end

end
