class CreateContactShares < ActiveRecord::Migration
  def change
    create_table :contact_shares do |t|
      t.integer :user_id
      t.integer :contact_id

      t.timestamps
    end
  end
end
