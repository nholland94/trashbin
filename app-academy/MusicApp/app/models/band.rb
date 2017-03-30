class Band < ActiveRecord::Base
  attr_accessible :name
  validates :name, presence: true

  has_many(
    :albums,
    class_name: "Album",
    primary_key: :id,
    foreign_key: :artist_id,
    dependent: :destroy
  )
end
