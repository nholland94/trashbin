class Link < ActiveRecord::Base
  attr_accessible :title, :url, :text, :user_id
  validates :title, :url, presence: true
  validates_format_of :url,
    with: /^(https?:\/\/)?([a-z0-9]{1,64}(\.|-)){1,40}[\w\/]+\/?$/i
    # /^https?:\/\/([a-z0-9]{1,26}(\.|-)){1,40}\w+\/?$/i

  has_many :link_subs
  has_many :subs, :through => :link_subs
  has_many :comments
  belongs_to :user

  def comments_by_parent_id
    first_layer = self.comments.where(parent_comment_id: nil)
    comments_with_karma = {}

    comments = {}
    first_layer.each do |super_comment|
      comments[super_comment.id] = super_comment.children_by_id
      comments_with_karma[super_comment.id] = super_comment.karma
    end

    comments.sort_by { |k, v| -1 * comments_with_karma[k] }
  end

end