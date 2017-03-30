# Load the rails application
require File.expand_path('../application', __FILE__)
require './lib/twitter_session.rb'

TwitterSession.instance

# Initialize the rails application
TwitterClient::Application.initialize!
