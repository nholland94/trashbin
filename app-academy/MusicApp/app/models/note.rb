class Note < ActiveRecord::Base
  attr_accessible :body, :user_id, :track_id
  validates :body, :user_id, :track_id, presence: true

  belongs_to :user
  belongs_to :track
end
