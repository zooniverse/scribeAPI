class Group
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,            type: String
  field :description,     type: String
  field :cover_image_url, type: String
  field :external_url,    type: String
  field :meta_data,       type: Hash
  field :stats,           type: Hash

  belongs_to :project
  has_many :subjects

  def update_stats
    
  end
end
