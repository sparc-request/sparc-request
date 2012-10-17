class AddPostionColumnToVisits < ActiveRecord::Migration
  def change
    add_column :visits, :position, :integer
  end
end
