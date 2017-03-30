class Comment < ActiveRecord::Base
  attr_accessible :text, :parent_comment_id, :link_id, :user_id

  belongs_to :link
  belongs_to :user

  belongs_to(
    :parent,
    class_name: "Comment",
    primary_key: :id,
    foreign_key: :parent_comment_id
  )

  has_many :user_comment_votes

  has_many(
    :children,
    class_name: "Comment",
    primary_key: :id,
    foreign_key: :parent_comment_id
  )

  def karma
    user_comment_votes.sum(:value)
  end

  def children_by_id
    comments_with_karma = {}
    nested_comments = {}

    self.children.each do |child|
      nested_comments[child.id] = child.children_by_id
      comments_with_karma[child.id] = child.karma
    end

    nested_comments.sort_by { |k, v| -1 * comments_with_karma[k] }
  end
end
