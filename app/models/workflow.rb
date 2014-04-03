class Workflow 
  include Mongoid::Document
  
  field    :name, 				type: String 
  field    :tasks, 				type: Array 
  field    :retire, 		    type: Integer, default: 10
  field    :enables_workflows,  type: Hash


  has_many :classifications 
  belongs_to :project
end