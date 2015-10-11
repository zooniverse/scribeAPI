class Favourite
  include Mongoid::Document

  belongs_to :subject
  belongs_to :user
  validates_uniqueness_of :user_id, scope: :subject_id , message: "this user has already favourited this subject"

  index user_id: 1, subject_id: 1
end
