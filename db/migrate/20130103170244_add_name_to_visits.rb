class AddNameToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :name, :string
  end
end
