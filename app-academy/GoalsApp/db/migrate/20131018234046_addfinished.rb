class Addfinished < ActiveRecord::Migration
  def change
    add_column :goals, :finished, :boolean
    change_column :goals, :finished, :boolean, :null => false
  end

end
