class Goal < ActiveRecord::Base
  attr_accessible :body, :is_private, :title, :user_id, :finished

  after_initialize :default_values

  validates :body, :presence => true
  validates :title, :presence => true
  validates :user_id, :presence => true
  validates :is_private, :inclusion => { :in => [false, true] }
  validates :finished, :inclusion => { :in => [false, true] }

  belongs_to :user

  def default_values
    self.finished ||= false
  end


end
