class AddLockedToProtocols < ActiveRecord::Migration[5.1]
  def change
    add_column :protocols, :locked, :boolean
  end
end
