class AddIsHispanicToIdentities < ActiveRecord::Migration[4.2]
  def change
    add_column :identities, :is_hispanic, :boolean
  end
end
