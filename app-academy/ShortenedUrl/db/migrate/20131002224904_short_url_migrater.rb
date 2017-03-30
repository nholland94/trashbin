class ShortUrlMigrater < ActiveRecord::Migration
  def up
    remove_column :short_urls, :short_url
    add_column :short_urls, :code, :string
  end

  def down
    add_column :short_urls, :short_url, :string
    remove_column :short_urls, :code
  end
end
