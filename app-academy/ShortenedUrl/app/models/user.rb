class User < ActiveRecord::Base
  attr_accessible :email

  has_many(
    :submitted_urls,
    :class_name => "ShortUrl",
    :foreign_key => :submitter_id,
    :primary_key => :id
  )

  has_many(
    :visits,
    :class_name => "Visit",
    :foreign_key => :user_id,
    :primary_key => :id
  )

  has_many(
    :visited_urls,
    :through => :visits,
    :source => :short_url,
    :uniq => true
  )
end
