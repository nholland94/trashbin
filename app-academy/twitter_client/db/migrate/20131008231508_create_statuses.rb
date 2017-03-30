class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.integer :twitter_status_id
      t.integer :twitter_user_id
      t.string :body

      t.timestamps
    end
  end
end
