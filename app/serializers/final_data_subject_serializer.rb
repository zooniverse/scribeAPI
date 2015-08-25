class FinalDataSubjectSerializer < ActiveModel::MongoidSerializer

  attributes :id, :type, :location, :region, :width, :height, :meta_data
  attributes :data # , :task
  attributes :classification_count
  attributes :generated_in_workflow
  attributes :child_subjects

  def attributes
    data = super

    # For brevity, remove attributes that are redundant or always null:
    
    if data[:type] == 'root'
      # Root subjects don't have data:
      data.delete :data
      data.delete :generated_in_workflow

    else
      # All of these are inherited from parent subject, so remove:
      data.delete :location
      data.delete :width
      data.delete :height
      data.delete :meta_data
    end 

    if data[:generated_in_workflow] == 'mark'
      # Mark subjects have roughly same info in :data and :region so keep :region
      data.delete :data
    else
      # .. For all other child subjects, delete :region since it's avail in parent
      data.delete :region
    end

    data.delete :child_subjects if data[:child_subjects].empty?

    data
  end 

  def generated_in_workflow
    return nil if object.parent_subject.nil? 
    puts "parent subj: #{object}"
    object.parent_subject.classifications.first.workflow.name
  end

  def child_subjects
    object.child_subjects.map { |s| FinalDataSubjectSerializer.new(s, root: false) }
  end

  def task
    return nil if object.parent_workflow_task.nil? 

    task = object.parent_workflow_task
    {
      instruction: task.instruction,
      help: task.help,
      tool: task.tool,
      tool_config: task.tool_config
    }
  end

  def classification_count
    object.classifications.count
  end

  def id
    object._id.to_s
  end

  def include_data?
    ! object.data.nil?
  end

  def include_task?
    ! object.parent_workflow_task.nil?
  end

end
