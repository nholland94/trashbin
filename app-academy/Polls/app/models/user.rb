class User < ActiveRecord::Base
  attr_accessible :user_name
  validates :user_name, presence: true

  has_many(
  :authored_polls,
  class_name: 'Poll',
  primary_key: :id,
  foreign_key: :author_id
  )

  has_many(
  :responses,
  class_name: 'Response',
  primary_key: :id,
  foreign_key: :user_id
  )
end
