class Indices < ActiveRecord::Migration
  def change
    add_index(:users, :twitter_user_id, {unique: true})
    add_index(:statuses, :twitter_status_id, {unique: true})
  end
end
