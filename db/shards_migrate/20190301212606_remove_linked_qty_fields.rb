class RemoveLinkedQtyFields < ActiveRecord::Migration[5.2]
  using_group(:shards)

  def change
    remove_column :service_relations, :linked_quantity
    remove_column :service_relations, :linked_quantity_total
  end
end
