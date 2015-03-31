class Group
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key,             type: String
  field :name,            type: String
  field :description,     type: String
  field :cover_image_url, type: String
  field :external_url,    type: String
  field :meta_data

  belongs_to :project
  has_many :subject_sets

end
