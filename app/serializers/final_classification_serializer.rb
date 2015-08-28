class FinalClassificationSerializer < ActiveModel::MongoidSerializer
  attributes :_id, :task_key, :started_at, :finished_at, :subject_id, :annotation
end
