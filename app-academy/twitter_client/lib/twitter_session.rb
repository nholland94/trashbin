require 'singleton'

class TwitterSession
  include Singleton

  CONSUMER_KEY = 'gCiJJhXel5G1h43EzDcDw'
  CONSUMER_SECRET = 'b1qhWu071lcaV9UM7heNp9e7ris7Jlo4RvIvGiWkSk'
  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

  attr_reader :access_token

  def initialize
    @access_token = get_token('token')
  end

  def self.get(*args)
    self.instance.access_token.get(*args).body
  end

  def self.post(*args)
    self.instance.access_token.set(*args)
  end

  protected

  def request_access_token
    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url
    puts "Go to this URL: #{authorize_url}"
    Launchy.open(authorize_url)

    puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp
    request_token.get_access_token( :oauth_verifier => oauth_verifier )
  end

  def get_token(token_file)
    if File.exist?(token_file)
      File.open(token_file) { |f| YAML.load(f) }
    else
      access_token = request_access_token
      File.open(token_file, 'w') { |f| YAML.dump(access_token, f) }
      access_token
    end
  end
end