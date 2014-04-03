class Classification 
  include Mongoid::Document
  
  field :annotations, type: Array

  belongs_to :workflow
  belongs_to :user
  belongs_to :subject
  
end