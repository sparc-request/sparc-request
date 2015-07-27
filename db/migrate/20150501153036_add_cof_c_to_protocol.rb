class AddCofCToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :has_cofc, :boolean
  end
end
