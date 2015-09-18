class SubjectSerializer < ActiveModel::MongoidSerializer

  attributes :id, :type, :parent_subject_id, :workflow_id, :name, :location, :data, :region, :classification_count, :order, :meta_data
  attributes :width, :height, :region, :subject_set_id, :status
  attributes :user_favourite, :user_has_classified, :user_has_deleted # , :classifying_user_ids
  attributes :belongs_to_user, :created_by_user_id
  attributes :child_subjects

  delegate :current_or_guest_user, to: :scope
  delegate :current_user, to: :scope
  # has_many :child_subjects

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

  def type
    object.type.nil? ? 'subjects' : object.type
  end

  # Let's override default has_many so that we can restrict to active (i.e. to hide retired marks)
  def child_subjects
    object.child_subjects.active.map { |s| SubjectSerializer.new(s, root: false, scope: scope) }
  end

  def workflow_id
    object.workflow_id.to_s
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
    user = scope.nil? ? nil : current_or_guest_user
    user and user.has_favourite?(object)
  end

  def user_has_deleted
    user = scope.nil? ? nil : current_or_guest_user
    # user and user.has_classified?(object)
    unless user == nil
      return object.deleting_user_ids.include?(user.id.to_s)
    end
  end

  def user_has_classified
    user = scope.nil? ? nil : current_or_guest_user
    # user and user.has_classified?(object)
    unless user == nil
      return object.classifying_user_ids.include?(user.id.to_s) # Alternate method? --STI
    end
  end

  def belongs_to_user
    user = scope.nil? ? nil : current_or_guest_user
    unless user == nil
      return object.created_by_user_id == user.id.to_s
    end
  end

end
