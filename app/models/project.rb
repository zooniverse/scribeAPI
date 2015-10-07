
class Project
  include Mongoid::Document
  include Mongoid::Timestamps

  field  :key ,              type: String # unique key identifying project (subfolder under /projects holding project jsons)
  field  :producer ,         type: String, default: "Adler"
  field  :title ,            type: String, default: "ZooZoo"
  field  :short_title,       type: String, default: "Scribe 2.0"
  field  :team,              type: Array
  field  :summary ,          type: String, default: "Classify pictures of zoo's"
  field  :description,       type: String, default: "We need your help to understand zoo's better"
  field  :home_page_content, type: String, default: "<p>Page content goes here</p>"
  field  :organizations,     type: Array,  default: [{name: "zooniverse", location: "Chicago IL", description: "provides opportunities for people around the world to contribute to real discoveries", url:["https://www.zooniverse.org/"]}]
  field  :scientists,        type: Array,  default: [{name: "Stuart Lynn", location: "Chicago, IL", description: "me", url:["https://github.com/brian-c"]}]
  field  :developers,        type: Array,  default: [{name: "Stuart Lynn", location: "Chicago, IL", description: "me", url:["https://github.com/brian-c"]}]
  field  :pages,             type: Array,  default: []
  field  :logo,              type: String
  field  :background,        type: String
  field  :forum,             type: Hash
  field  :feedback_form_url, type: String
  field  :discuss_url,       type: String
  field  :blog_url,          type: String
  field  :privacy_policy,    type: String
  field  :styles,            type: String
  field  :custom_js,         type: String
  field  :admin_email,       type: String
  field  :team_emails,       type: Array
  field  :metadata_search,   type: Hash
  field  :tutorial,          type: Hash
  field  :terms_map,         type: Hash, default: {} # Hash mapping internal terms to project appropriate terms (e.g. 'group'=>'ship')
  field  :status,            type: String, default: 'inactive'
  field :analytics,          type: Hash

  include CachedStats
  update_interval 30

  has_many :groups, dependent: :destroy
  has_many :subject_sets
  has_many :workflows, dependent: :destroy, order: "order ASC"
  has_many :subjects

  scope :most_recent, -> { order(updated_at: -1) }
  scope :active, -> { where(status: 'active') }

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

  def calc_stats
    # amount of days to calculate statistics for
    range_in_days = 60
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

    # retrieve subject data
    subjects_data = []
    subject_groups = Subject.all.group_by {|d| d.status}
    subject_groups.each do |status, subjects|
      subjects_data << {
        label: status,
        value: subjects.size
      }
    end

    # retrieve classification data in range
    classifications_data = []
    classifications_in_range = Classification.where(:created_at => start_date..end_date).group_by {|d| d.created_at.strftime(datetime_format)}
    (start_date.to_i..end_date.to_i).step(1.hour) do |i_date|
      n_date = Time.at(i_date).utc
      hour = n_date.strftime(datetime_format)
      classifications_data << {
        date: hour,
        value: classifications_in_range[hour] ? classifications_in_range[hour].size : 0
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
      subjects: {
        count: total_subjects,
        data: subjects_data
      },
      classifications: {
        count: total_classifications,
        data: classifications_data
      }
    }
  end

end
