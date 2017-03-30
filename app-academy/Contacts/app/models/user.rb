class User < ActiveRecord::Base
  attr_accessible :name, :email
  validates :name, :email, :presence => true
  validates :name, :email, :uniqueness => true

  has_many(
    :contacts,
    :class_name => "Contact",
    :primary_key => :id,
    :foreign_key => :user_id)

  has_many(
    :contact_shares,
    :class_name => "ContactShare",
    :primary_key => :id,
    :foreign_key => :user_id)

  has_many :shared_contacts, :through => :contact_shares, :source => :contact

  def all_contacts
    contacts + shared_contacts
  end
end
