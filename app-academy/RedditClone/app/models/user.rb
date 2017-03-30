require 'bcrypt'

class User < ActiveRecord::Base
  attr_accessible :username, :password, :session_token
  attr_reader :password

  before_validation do
    self.session_token ||= self.class.generate_session_token
  end

  validates :username, :password_digest, :session_token, :presence => true
  validates :username, :uniqueness => true
  validates :password, length: { minimum: 6, allow_nil: true }

  has_many(
    :subs,
    class_name: "Sub",
    primary_key: :id,
    foreign_key: :moderator_id
  )

  has_many :links
  has_many :comments
  has_many :user_comment_votes

  has_many :comments_voted_on, through: :user_comment_votes, source: :comment

  def self.generate_session_token
    SecureRandom.urlsafe_base64
  end

  def self.find_by_credentials(username, password)
    user = User.find_by_username(username)

    return user if user && user.is_password?(password)

    nil
  end

  def reset_session_token!
    self.session_token = self.class.generate_session_token
    self.save!
    self.session_token
  end

  def password=(raw_pass)
    @password = raw_pass
    self.password_digest = BCrypt::Password.create(raw_pass)
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end
end
