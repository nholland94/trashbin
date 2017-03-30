class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text    :text,              :null => false
      t.integer :parent_comment_id
      t.integer :link_id,           :null => false

      t.timestamps
    end
  end
end
