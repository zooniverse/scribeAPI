class Group
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key,             type: String
  field :name,            type: String
  field :description,     type: String
  field :cover_image_url, type: String
  field :external_url,    type: String
  field :meta_data,       type: Hash

  include CachedStats
  update_interval 30

  belongs_to :project
  has_many :subject_sets, dependent: :destroy
  has_many :subjects

  scope :by_project, -> (project_id) { where(project_id: project_id) }

  index "project_id" => 1

  def calc_stats

    statuses = {
      'active' => 0,
      'inactive' => 0,
      'retired' => 0,
      'complete' => 0,
    }.merge Subject.group_by_field_for_group(self, :status)

    finished = statuses['complete'] + statuses['retired']
    pending = statuses['active'] + statuses['inactive']

    # Sum total_subjects and active_subjects counts for all workflows:
    workflow_counts = Subject.group_by_field_for_group(self, :workflow_id).inject({}) { |h, (id, c)| h[id.to_s] = {"total_subjects" => c} if id; h }
    workflow_counts = Subject.group_by_field_for_group(self, :workflow_id, {status: 'active'}).inject(workflow_counts) { |h, (id, c)| h[id.to_s] = h[id.to_s].merge({"active_subjects" => c}) if id; h }

    ret = {
      total_finished: finished,
      total_pending: pending,
      completeness: finished.to_f / (pending + finished),
      workflow_counts: workflow_counts
    }

    ret
  end
end
