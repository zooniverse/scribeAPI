class SubjectSerializer < ActiveModel::MongoidSerializer

  attributes :id, :subject_set_id, :parent_subject_id, :workflow_id, :type, :name, :location, :data, :region, :classification_count, :child_subjects_info, :meta_data, :user_favourite # , :key #PB deprecating this; unused
  attributes :width, :height, :region

  delegate :current_user, to: :scope

  has_many :child_subjects

  def id
    object._id.to_s
  end

  def subject_set_id
    object.subject_set_id.to_s
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
        tool_type: child.region['toolName'],
      }

      child_subject_info << rebuild_info

    end
  end

end
