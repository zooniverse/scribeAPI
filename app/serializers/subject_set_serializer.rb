class SubjectSetSerializer < ActiveModel::MongoidSerializer

  attributes :id, :name, :thumbnail, :meta_data, :subjects, :state, :counts, :group_id, :subjects_page_info
  has_many :subjects


  def id
    object._id.to_s
  end

  def subjects
    workflow_id = serialization_options[:workflow_id]
    limit = serialization_options[:limit].to_i
    random = serialization_options[:random]

    return nil if object.nil?

    # we will have to send the page through serialization_options
    if random
      subjects = Kaminari.paginate_array(object.subjects.active_root.where(workflow_id: workflow_id).random(limit: limit)).page(serialization_options[:page])      
    else
      subjects = Kaminari.paginate_array(object.subjects.active_root.where(workflow_id: workflow_id).limit(limit)).page(serialization_options[:page])
    end

    subjects_page_info = {
      current_page: subjects.current_page,
      next_page: subjects.next_page,
      prev_page: subjects.prev_page,
      total_pages: subjects.total_pages,
    }
    # subjects["subjects_page_info"] = subjects_page_info # how do I add this info in
  end

end
