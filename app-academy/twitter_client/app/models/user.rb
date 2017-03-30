require 'addressable/uri'
require 'json'
require './lib/twitter_session'

class User < ActiveRecord::Base
  attr_accessible :twitter_user_id, :screen_name
  validates :twitter_user_id, :screen_name, presence: true

  has_many(
    :statuses,
    :primary_key => :twitter_user_id,
    :foreign_key => :twitter_user_id,
    :class_name => 'Status'
  )

  def self.fetch_by_screen_name(name)
    url = Addressable::URI.new(
      scheme: 'https',
      host: 'api.twitter.com',
      path: '1.1/users/show.json',
      query_values: {
        screen_name: name
      }
    ).to_s

    json_user = TwitterSession.get(url)
    p json_user

    self.parse_twitter_params(JSON::parse(json_user))
  end

  def self.parse_twitter_params(params)
    new({twitter_user_id: params['id'],
      screen_name: params['screen_name']})
  end

  def sync_statuses
    statuses = Status.fetch_statuses_for_user(self)
    statuses.each do |status|
      unless status.persisted?
        status.save!
      end
    end
  end
end
