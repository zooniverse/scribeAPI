class Project
	include Mongoid::Document
	include Mongoid::Timestamps

	field  :producer, 		 				type: String
	field  :title, 		   					type: String
	field  :home_page_content,		type: String
	field  :summary, 		 					type: String
	field  :description, 					type: String
	field  :organizations, 				type: Array
	field  :scientists, 	 				type: Array
	field  :developers, 	 				type: Array
	field  :pages,         				type: Array
	field  :background,    				type: String

	has_many :groups
	has_many :workflows
	has_many :subjects

end
