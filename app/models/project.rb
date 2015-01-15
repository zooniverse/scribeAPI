class Project
	include Mongoid::Document

	field  :producer , 		 type: String, default: "Adler"
	field  :title , 		   type: String, default: "ZooZoo"
	field  :summary , 		 type: String, default: "Classify pictures of zoo's"
	field  :description, 	 type: String, default: "We need your help to understand zoo's better"
	field  :organizations, type: Array,  default: [{name: "zooniverse", location: "Chicago IL", description: "blah balh", url:["https://www.zooniverse.org/"]}]
	field  :scientists, 	 type: Array,  default: [{name: "Stuart Lynn", location: "Chicago, IL", description: "me", url:["https://github.com/brian-c"]}]
	field  :developers, 	 type: Array,  default: [{name: "Stuart Lynn", location: "Chicago, IL", description: "me", url:["https://github.com/brian-c"]}]
	field  :pages,         type: Array,  default: []
	field  :background,    type: String 

	has_many :workflows
	has_many :subjects
end