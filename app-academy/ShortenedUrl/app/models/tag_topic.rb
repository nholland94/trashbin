class TagTopic < ActiveRecord::Base
  attr_accessible :tag

  has_many(
    :taggings,
    :class_name => "Tagging",
    :foreign_key => :tag_topic_id,
    :primary_key => :id
  )

  has_many(
    :short_urls,
    :through => :taggings,
    :source => :short_url
  )

  def self.popular_links_by_tag
    most_popular = {}
    self.all.each do |tag_topic|
      best_url = nil
      best_url_clicks = 0

      ShortUrl.all.each do |url|
        if url.tags.include?(TagTopic.find_by_tag(tag_topic.tag))
          if url.num_clicks > best_url_clicks
            best_url = url
            best_url_clicks = url.num_clicks
          end
        end
      end

      most_popular[tag_topic.tag] = best_url
    end
    most_popular
  end
end