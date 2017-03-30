class CreateShortUrls < ActiveRecord::Migration
  def change
    create_table :short_urls do |t|
      t.string :long_url
      t.string :short_url
      t.integer :submitter_id

      t.timestamps
    end

    add_index(:short_urls, :short_url, {unique: true})
  end
end
