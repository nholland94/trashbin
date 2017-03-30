require "bcrypt"
require "securerandom"

class User < ActiveRecord::Base
  attr_accessible :email, :session_token, :password, :activated, :activation_token, :admin
  attr_reader :password
  validate :ensure_session_token
  validate :ensure_activation_token
  validates :password, length: { 
    minimum: 6,
    maximum: 18,
    too_short: "must have at least 6 characters",
    too_long: "must be under 18 characters",
    allow_nil: true
  }
  validates :email, :session_token, :password_digest, :activation_token, presence: true

  has_many :notes

  def self.generate_activation_token
    SecureRandom.urlsafe_base64(24)
  end

  def self.generate_session_token
    SecureRandom.urlsafe_base64(16)
  end

  def self.find_by_credentials(email, raw_password)
    user = User.find_by_email(email)

    if user && user.is_password?(raw_password)
      return user
    end
    
    nil
  end

  def password=(raw_password)
    self.password_digest = BCrypt::Password.create(raw_password)
  end

  def is_password?(raw_password)
    BCrypt::Password.new(self.password_digest).is_password?(raw_password)
  end

  def reset_session_token!
    self.session_token = self.class.generate_session_token
    self.save!
  end

  def ensure_session_token
    self.session_token || self.session_token = self.class.generate_session_token
  end

  def ensure_activation_token
    self.activation_token || self.activation_token = self.class.generate_activation_token
  end

  def ensure_activated_boolean
    self.activated || self.activated = false
  end
end