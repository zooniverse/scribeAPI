class Workflow
  include Mongoid::Document
  include Mongoid::Timestamps

  # field    :key, 				        type: String
  field  :name,                type: String
  field  :label,               type: String
  field  :tasks, 			      	 type: Hash
  field  :first_task,          type: String
  field  :retire_limit, 		   type: Integer, default: 10
  field  :subject_fetch_limit, type: Integer, default: 5
  field  :enables_workflows,   type: Hash
  field  :active_subjects,     type: Integer, default: 0

  has_many :classifications
  belongs_to :project

  def trigger_follow_up_workflow(subject)
  	enables_workflows.each_pair do |workflow_id, details|
  		# for_each
  		# details["averaged_keys"]
  	end
  end
end
