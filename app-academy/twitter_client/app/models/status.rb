require 'json'
require 'addressable/uri'
require './lib/twitter_session'

class Status < ActiveRecord::Base
  attr_accessible :twitter_status_id, :twitter_user_id, :body
  validates :twitter_status_id, :twitter_user_id, :body, presence: true

  belongs_to(
    :user,
    :primary_key => :twitter_user_id,
    :foreign_key => :twitter_user_id,
    :class_name => 'User'
  )

  def self.parse_twitter_params(params)
    self.new(twitter_user_id: params['user']['id'],
      twitter_status_id: params['id'],
      body: params['text'])
  end

  def self.fetch_statuses_for_user(user)
    url = Addressable::URI.new(
      scheme: 'https',
      host: 'api.twitter.com',
      path: '1.1/statuses/user_timeline.json',
      query_values: {
        user_id: user.twitter_user_id
      }
    ).to_s

    json_statuses = TwitterSession.get(url)

    JSON::parse(json_statuses).map do |status|
      if Status.find_by_twitter_status_id(status['id']).nil?
        self.parse_twitter_params(status)
      else
        Status.find_by_twitter_status_id(status['id']).first
      end
    end
  end

end
