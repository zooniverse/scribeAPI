class Classification 
  include Mongoid::Document
  
  field :annotations, type: Array

  belongs_to :workflow
  belongs_to :user
  belongs_to :subject

  after_save :generate_new_subjects 

  def generate_new_subjects
    
  end
  
end