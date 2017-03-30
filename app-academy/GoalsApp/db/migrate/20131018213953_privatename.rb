class Privatename < ActiveRecord::Migration
  def up
    rename_column :goals, :private, :is_private
  end

  def down
    rename_column :goals, :is_private, :private
  end
end
