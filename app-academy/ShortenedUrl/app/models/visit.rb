class Visit < ActiveRecord::Base
  attr_accessible :user_id, :short_url_id

  belongs_to(
    :user,
    :class_name => "User",
    :foreign_key => :user_id,
    :primary_key => :id
  )

  belongs_to(
    :short_url,
    :class_name => "ShortUrl",
    :foreign_key => :short_url_id,
    :primary_key => :id
  )

  def self.record_visit!(user, short_url)
    Visit.new({user_id: user.id, short_url: short_url.id})
  end
end
