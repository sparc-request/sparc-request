class RemoveLinkedQtyFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :service_relations, :linked_quantity
    remove_column :service_relations, :linked_quantity_total
  end
end
