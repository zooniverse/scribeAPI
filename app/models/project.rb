
class Project
  include Mongoid::Document
  include Mongoid::Timestamps

  field  :key ,              type: String # unique key identifying project (subfolder under /projects holding project jsons)
  field  :author,            type: String, default: "NYPL/Zooniverse"
  field  :title,             type: String, default: "Project X: A Scribe Project"
  field  :short_title,       type: String, default: "Project X"
  field  :team,              type: Array,  default: []
  field  :summary ,          type: String, default: "Scribe is a crowdsourcing framework for transcribing handwritten or OCR-resistant documents."
  field  :description,       type: String, default: "Scribe is particularly geared toward digital humanities, library, and citizen science projects seeking to extract highly structured, normalizable data from a set of digitized materials (e.g. historical manuscripts, account ledgers, or maritime logbooks) in order to enable further analysis, metadata enrichment, and discovery. Scribe is not a crowdsourcing project in a box, but it establishes the foundation for a developer to configure and launch a project far more easily than if starting from scratch."
  field  :keywords,          type: String, default: "transcription, digital humanities, citizen science, crowdsourcing, metadata"
  field  :home_page_content, type: String, default: "<p>There is currently no content on the home page.</p>"
  field  :organizations,     type: Array,  default: []
  field  :scientists,        type: Array,  default: []
  field  :developers,        type: Array,  default: []
  field  :pages,             type: Array,  default: []
  field  :menus,             type: Hash,   default: {}
  field  :partials,          type: Hash,   default: {}
  field  :logo,              type: String,  default: nil
  field  :background,        type: String,  default: nil
  field  :favicon,           type: String,  default: nil
  field  :forum,             type: Hash,    default: nil
  field  :feedback_form_url, type: String
  field  :discuss_url,       type: String
  field  :blog_url,          type: String
  field  :privacy_policy,    type: String
  field  :styles,            type: String
  field  :custom_js,         type: String
  field  :admin_email,       type: String
  field  :team_emails,       type: Array,   default: []
  field  :metadata_search,   type: Hash
  field  :tutorial,          type: Hash
  field  :terms_map,         type: Hash, default: {} # Hash mapping internal terms to project appropriate terms (e.g. 'group'=>'ship')
  field  :status,            type: String, default: 'inactive'
  field  :analytics,         type: Hash,    default: nil
  field  :downloadable_data, type: Boolean

  # 10.27.15 until we can sort out a better time to call this method, lets comment it out.
  include CachedStats
  update_interval 300

  has_many :groups, dependent: :destroy
  has_many :subject_sets
  has_many :workflows, dependent: :destroy, order: "order ASC"
  has_many :subjects
  has_many :final_subject_sets
  has_many :final_data_exports

  scope :most_recent, -> { order(updated_at: -1) }
  scope :active, -> { where(status: 'active') }

  index "status" => 1

  def activate!
    return if self.status == 'active'

    self.class.active.each do |p|
      p.update_attributes status: 'inactive'
    end
    self.update_attributes status: 'active'
  end

  def self.current
    active.first
  end

  # get Distinct export_names from all workflow_tasks
  def export_names
    workflows.inject([]) do |a, w|
      a += w.tasks.map { |t| t.export_name }

    end.select do |n| 
      ! n.nil? 

    end.inject({}) do |h, name|
      key = name.gsub(' ', '-').gsub(/[^A-Za-z0-9-]/, '')
      h[key] = name
      h
    end
  end

  def calc_stats
    # amount of days to calculate statistics for
    range_in_days = 7
    datetime_format = "%Y-%m-%d %H:00"

    # determine date range
    current_time = Time.now.utc # Time.new
    end_date = current_time
    start_date = end_date - range_in_days.days

    # calculate total counts
    total_users = User.count
    total_subjects = Subject.count
    total_classifications = Classification.count

    # retrieve user data in range
    users_data = []
    users_in_range = User.where(:created_at => start_date..end_date).group_by {|d| d.created_at.strftime(datetime_format)}
    (start_date.to_i..end_date.to_i).step(1.hour) do |i_date|
      n_date = Time.at(i_date).utc
      hour = n_date.strftime(datetime_format)
      users_data << {
        date: hour,
        value: users_in_range[hour] ? users_in_range[hour].size : 0
      }
    end

    # retrieve subject statuses by workflow:
    workflow_counts = {}
    workflows.each do |workflow|
      workflow_counts[workflow.name] = {total: workflow.subjects.count, data: []}
      groups = Subject.group_by_field(:status, {workflow_id: workflow.id})
      groups.each do |(v, count)|
        workflow_counts[workflow.name][:data] << { label: v, value: count }
      end
    end

    # retrieve classification data in range
    classifications_in_range = Classification.group_by_hour({"created_at" => {"$gte" => start_date}}).inject({}) do |h,(rec,total)|
      hour = "#{rec['y']}-#{rec['m']}-#{'%02d' % rec['d']} #{rec['h']}:00"
      h[hour] = total
      h
    end

    classifications_data = []
    (start_date.to_i..end_date.to_i).step(1.hour) do |i_date|
      n_date = Time.at(i_date).utc
      hour = n_date.strftime(datetime_format)
      classifications_data << {
        date: hour,
        value: classifications_in_range[hour] ? classifications_in_range[hour] : 0
      }
    end

    {
      updated_at: current_time.strftime(datetime_format),
      start_date: start_date.strftime(datetime_format),
      end_date: current_time.strftime(datetime_format),
      users: {
        count: total_users,
        data: users_data
      },
      workflow_counts: workflow_counts,
      classifications: {
        count: total_classifications,
        data: classifications_data
      }
    }
  end

end
