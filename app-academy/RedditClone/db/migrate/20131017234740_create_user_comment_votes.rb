class CreateUserCommentVotes < ActiveRecord::Migration
  def change
    create_table :user_comment_votes do |t|
      t.integer :user_id
      t.integer :comment_id
      t.integer :value

      t.timestamps
    end

    add_index :user_comment_votes, :user_id
    add_index :user_comment_votes, :comment_id
  end
end
