class Project
	include Mongoid::Document
	include Mongoid::Timestamps

	field  :title, 		   					type: String
	field  :summary, 		 					type: String
	field  :home_page_content,		type: String
	field  :organizations, 				type: Array
	field	 :team,									type: Array
	field  :pages,         				type: Array
	field  :background,    				type: String

	has_many :groups
	has_many :workflows
	has_many :subjects

end
