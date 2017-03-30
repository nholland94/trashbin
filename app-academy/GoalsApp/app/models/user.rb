require 'bcrypt'

class User < ActiveRecord::Base
  attr_accessible :password, :session_token, :username
  attr_reader :password
  validates :password, :presence => true, :length => {:minimum => 6}
  validates :username, :presence => true
  validates :session_token, :presence => true

  has_many :goals

  after_initialize :ensure_session_token



  def self.find_by_credentials(username, password)
    u = User.find_by_username(username)
    return nil if u.nil?
    u.is_password?(password) ? u : nil
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def self.generate_session_token
    SecureRandom::urlsafe_base64
  end

  def ensure_session_token
    self.session_token ||= self.class.generate_session_token
  end

  def reset_session_token
    self.update_attributes(session_token: self.class.generate_session_token)
  end

end
