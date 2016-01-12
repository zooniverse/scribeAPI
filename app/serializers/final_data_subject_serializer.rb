class FinalDataSubjectSerializer < ActiveModel::MongoidSerializer

  attributes :id, :type, :location, :region, :width, :height, :meta_data
  attributes :data # , :task
  attributes :status
  # attributes :classification_count
  attributes :generated_in_workflow
  # attributes :child_subjects
  attributes :transcription_classifications

  attributes :assertions_breakdown
  attributes :classifications_breakdown
  attributes :assertions

  # attributes :flagged_bad
  # ttributes :flagged_for_retirement
  attributes :flags

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
      data.delete :data if data[:region]
    else
      # .. For all other child subjects, delete :region since it's avail in parent
      data.delete :region
    end
    data.delete :transcription_classifications if data[:transcription_classifications].empty?
    # data.delete :child_subjects if data[:child_subjects].empty?

    data
  end 

  def assertions
    @assertions ||= flattened_subjects(object.child_subjects)
    @assertions
  end

  def classifications_breakdown
    all_classifications = []
    @all_subjects.each do |s|
      all_classifications += s.classifications
    end
    ret = all_classifications.inject({}) { |h, c| h[c.task_key] ||= 0; h[c.task_key] += 1; h }
    ret[:total] = object.classifications.count
    ret
  end

  def assertions_breakdown
    assertions.inject({}) do |h, a|
      h[:all_workflows] ||= {}
      h[:all_workflows][:total] ||= 0
      h[:all_workflows][:total] += 1
      h[:all_workflows][a.status] ||= 0
      h[:all_workflows][a.status] += 1

      h[a.created_in_workflow] ||= {}

      h[a.created_in_workflow][:total] ||= 0
      h[a.created_in_workflow][:total] += 1

      h[a.created_in_workflow][a.status] ||= 0
      h[a.created_in_workflow][a.status] += 1

      h
    end
  end

  def flattened_subjects(subjects, parents = [])
    @all_subjects ||= []
    @all_subjects += subjects

    ret = []
    subjects.each do |s|
      next if s.parent_classifications.limit(1).first.task_key == 'completion_assessment_task'

      if s.child_subjects.size > 0
        ret += flattened_subjects(s.child_subjects, parents + [s])

      else
        ret << FinalSubjectAssertionSerializer.new(subject: s, parents: parents)
      end
    end
    ret
  end

  def flags
    {
      complete: flagged_for_retirement,
      bad: {
        votes_in_favor: object.flagged_bad_count || 0
      }
    }
  end

  def flagged_for_retirement
    votes = object.number_of_completion_assessments
    h = {
      votes_in_favor: object.retire_count || 0,
      total_votes: votes,
    }
    h[:percentage_in_favor] = object.retire_count / votes.to_f if ! object.retire_count.nil? && votes > 0
    h
  end

  def status
    object.status
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

  def transcription_classifications
    transcribe_workflow_id = Workflow.where(name:"transcribe").to_a[0]._id
    transcription_classifications = object.classifications.where( {workflow_id: transcribe_workflow_id} ).to_a
    object.classifications.where( {workflow_id: transcribe_workflow_id} ).map{ |c| FinalClassificationSerializer.new(c, root: false) }
  end

end
