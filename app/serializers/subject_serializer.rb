class SubjectSerializer < ActiveModel::MongoidSerializer

  attributes :id, :type, :parent_subject_id, :workflow_id, :name, :location, :data, :region, :classification_count, :order, :meta_data, :user_favourite
  attributes :width, :height, :region, :subject_set_id, :status, :user_has_classified

  delegate :current_user, to: :scope
  has_many :child_subjects

  def attributes
    data = super
    if serialization_options[:but_not_all_fields]
      child_data[:id] = data.id
      child_data[:location_standard] = data[:location][:standard]
      child_data[:data] = data["data"]
      child_data[:region] = data[:region]
      child_data[:tool_type] = data[:region]['toolName']
      data = child_data
    else
      data
    end
    data
  end

  def workflow_id
    object.workflow_id.to_s
  end

  def user_has_classified
    object.user_has_classified
    # binding.pry
    # object.classifying_user_ids?.include?(current_or_guest_user.id.to_s) # how do I get current user id in here? --STI
  end

  def id
    object._id.to_s
  end

  def parent_subject_id
    object.parent_subject_id.to_s
  end

  def subject_set_id
    object.subject_set_id.to_s
  end

  def user_favourite
    (scope and scope.has_favourite?(object))
  end

end
