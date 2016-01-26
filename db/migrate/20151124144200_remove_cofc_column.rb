class RemoveCofcColumn < ActiveRecord::Migration
  def change
    remove_column :protocols, :has_cofc
  end
end