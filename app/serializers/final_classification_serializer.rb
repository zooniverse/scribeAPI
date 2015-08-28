class FinalClassificationSerializer < ActiveModel::MongoidSerializer
  attributes :id, :task_key, :started_at, :finished_at, :subject_id, :annotation
  def id
    object._id.to_s
  end
end
