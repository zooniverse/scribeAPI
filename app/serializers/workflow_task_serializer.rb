class WorkflowTaskSerializer < ActiveModel::MongoidSerializer
  attributes :key, :tool_config, :instruction, :next_task, :generates_subject_type, :tool

end
