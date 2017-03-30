class UserCommentVote < ActiveRecord::Base
  attr_accessible :user_id, :comment_id, :value
  validates :user_id, :comment_id, :value, presence: true
  validates :value, inclusion: { in: [1, -1] }
  validate :user_vote_uniqueness

  def user_vote_uniqueness
    user = User.find(self.user_id)
    if user.comments_voted_on.include?(Comment.find(self.comment_id))
      errors.add(:uniqueness, "can't have already voted on comment_id")
    end
  end

  belongs_to :user
  belongs_to :comment
end
