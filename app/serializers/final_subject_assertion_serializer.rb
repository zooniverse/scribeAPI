class FinalSubjectAssertionSerializer < ActiveModel::MongoidSerializer

  attributes :id, :status
  attributes :name
  attributes :created_in_workflow
  attributes :confidence
  attributes :data
  attributes :versions
  attributes :region
  attributes :task_key
  attributes :instructions

  root false

  def id
    object.id.to_s
  end

end
