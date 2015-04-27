class SubjectSerializer < ActiveModel::MongoidSerializer
  attributes :id, :parent_subject_id, :workflow_id, :name, :location, :classification_count, :child_subjects_info, :meta_data, :user_favourite
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
        uri: child.location["uri"],
        relationship_to_parent: child.location["spec"],
        tool_type: child.tool_task_description["type"],
        mark_label: child.tool_task_description["label"]
      }

      child_subject_info << rebuild_info
      
    end
    child_subject_info
  end

end
