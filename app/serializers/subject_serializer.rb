class SubjectSerializer < ActiveModel::MongoidSerializer

  attributes :id, :type, :parent_subject_id, :workflow_id, :name, :location, :data, :region, :classification_count, :child_subjects_info, :meta_data, :user_favourite
  delegate :current_user, to: :scope

  
  
  def id
    object._id.to_s
  end

  def user_favourite
    (scope and scope.has_favourite?(object))
  end

  def child_subjects_info
    
    child_subjects = object.child_subjects
    child_subject_info = []
    child_subjects.each do |child|

      rebuild_info = {
        id: child.id,
        location_standard: child.location["standard"],
        data: child.data,
        region: child.region,
        tool_type: child.data["toolName"],
        label: child.data["label"]
      }

      child_subject_info << rebuild_info

    end
    child_subject_info
  end

end
