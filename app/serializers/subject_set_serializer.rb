class SubjectSetSerializer < ActiveModel::MongoidSerializer

  attributes :id, :name, :thumbnail, :meta_data, :subjects, :state, :counts, :group_id

  def attributes
    data = super
    binding.pry
  end

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


    # subjects["subjects_page_info"] = subjects_page_info # how do I add this info in
  end

  # def subjects_page_info
  #   page_info = {
  #     current_page: object.subjects.current_page,
  #     next_page: object.subjects.next_page,
  #     prev_page: object.subjects.prev_page,
  #     total_pages: object.subjects.total_pages,
  #   }
  # end


end
