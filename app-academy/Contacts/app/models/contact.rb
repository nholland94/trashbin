class Contact < ActiveRecord::Base
  attr_accessible :name, :email, :user_id
  validates :name , :email, :user_id, :presence => true

  belongs_to(
    :user,
    :class_name => "User",
    :primary_key => :id,
    :foreign_key => :user_id)

  has_many(
    :contact_shares,
    :class_name => "ContactShare",
    :primary_key => :id,
    :foreign_key => :contact_id)

  has_many :users_shared, :through => :contact_shares, :source => :user

  def self.contacts_for_user_id(user_id)
    User.find(user_id).all_contacts
  end
end
