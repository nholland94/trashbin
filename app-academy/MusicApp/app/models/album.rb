class Album < ActiveRecord::Base
  attr_accessible :title, :artist_id
  validates :title, :artist_id, presence: true

  belongs_to(
    :artist,
    class_name: "Band",
    primary_key: :id,
    foreign_key: :artist_id
  )

  has_many :tracks, dependent: :destroy
end
