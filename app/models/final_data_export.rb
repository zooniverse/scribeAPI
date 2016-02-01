class FinalDataExport 
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :project
  field :path,                          type: String
  field :num_final_subject_sets,        type: Integer
 
  scope :most_recent, -> { order(updated_at: -1) }

end
