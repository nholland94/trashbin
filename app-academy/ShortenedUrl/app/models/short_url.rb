class ShortUrl < ActiveRecord::Base
  attr_accessible :submitter_id, :code, :long_url

  belongs_to(
    :submitter,
    :class_name => "User",
    :foreign_key => :submitter_id,
    :primary_key => :id
  )

  has_many(
    :visits,
    :class_name => "Visit",
    :foreign_key => :short_url_id,
    :primary_key => :id
  )

  has_many(
    :visitors,
    :through => :visits,
    :source => :user,
    :uniq => true
  )

  has_many(
    :taggings,
    :class_name => "Tagging",
    :foreign_key => :short_url_id,
    :primary_key => :id
  )

  has_many(
    :tags,
    :through => :taggings,
    :source => :tag_topic,
    :uniq => true
  )

  def self.random_code
    code = ""
    loop do
      code = SecureRandom.urlsafe_base64(4)
      break if ShortUrl.find_by_code(code).nil?
    end
    code
  end

  def self.create_for_user_and_long_url!(user, long_url)
    row = self.new({
      :long_url => long_url,
      :code => self.random_code,
      :submitter_id => user.id
    })
    row.save
    row
  end

  def num_clicks
    (Visit.where({short_url_id: self.id})).count
  end

  def num_uniques
    self.visitors.count
  end

  def num_recent_uniques
    self.visitors.count(:id, {uniq: true})
    # num = 0
#     self.visitors.each do |visitor|
#       visitor.visited_urls.each do |visited_url|
#         if visited_url.code == self.code && visit.created_at <= Time.now + 600
#           num += 1
#           break
#         end
#       end
#     end
#     num
  end
end
