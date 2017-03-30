class Sub < ActiveRecord::Base
  attr_accessible :name, :moderator_id

  validates :name, :moderator_id, :presence => true
  validates :name, :uniqueness => true

  belongs_to(
    :moderator,
    class_name: "User",
    primary_key: :id,
    foreign_key: :moderator_id
  )

  has_many :link_subs
  has_many :links, :through => :link_subs

end
