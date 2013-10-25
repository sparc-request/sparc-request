class RemoveNameFromVisits < ActiveRecord::Migration
  def up
  	remove_column :visits, :name
  end

  def down
  	add_column :visits, :name, :string
  end
end
