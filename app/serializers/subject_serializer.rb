class SubjectSerializer < ActiveModel::MongoidSerializer

  attributes :id, :type, :parent_subject_id, :workflow_id, :name, :location, :data, :region, :classification_count, :child_subjects_info, :order, :meta_data, :user_favourite # , :key #PB deprecating this; unused
  attributes :width, :height, :region, :subject_set_id
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
    object.child_subjects.map do |child|
      SubjectSerializer.new(child, but_not_all_fields: true)
    end
  end

end
