class Project
	include Mongoid::Document
	include Mongoid::Timestamps

	field  :producer , 		 type: String, default: "Adler"
	field  :title , 		   type: String, default: "ZooZoo"
	field	 :team,					 type: Array
	field  :summary , 		 type: String, default: "Classify pictures of zoo's"
	field  :description, 	 type: String, default: "We need your help to understand zoo's better"
	field  :home_page_content, type: String, default: "<p>Page content goes here</p>"
	field  :organizations, type: Array,  default: [{name: "zooniverse", location: "Chicago IL", description: "blah balh", url:["https://www.zooniverse.org/"]}]
	field  :scientists, 	 type: Array,  default: [{name: "Stuart Lynn", location: "Chicago, IL", description: "me", url:["https://github.com/brian-c"]}]
	field  :developers, 	 type: Array,  default: [{name: "Stuart Lynn", location: "Chicago, IL", description: "me", url:["https://github.com/brian-c"]}]
	field  :pages,         type: Array,  default: []
	field  :background,    type: String
	field  :forum,         type: Hash

	include CachedStats

	update_interval 10

	has_many :groups
	has_many :workflows, dependent: :destroy
	has_many :subjects

  scope :most_recent, -> { order(updated_at: -1) }
  
  def self.current
    # Get most recently updated, in lieu of some other project selection mechanism:
    most_recent.first
  end

	def calc_stats
		{now: Time.new}
	end

end
