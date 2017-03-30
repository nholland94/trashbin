class ContactShare < ActiveRecord::Base
  attr_accessible :user_id, :contact_id
  validates :user_id, :contact_id, :presence => true

  belongs_to(
    :user,
    :class_name => "User",
    :primary_key => :id,
    :foreign_key => :user_id)

  belongs_to(
    :contact,
    :class_name => "Contact",
    :primary_key => :id,
    :foreign_key => :contact_id)
end
