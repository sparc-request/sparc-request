class AddLinkedQuantitesToServiceRelations < ActiveRecord::Migration
  def change
    add_column :service_relations, :linked_quantity, :boolean, :default => false
    add_column :service_relations, :linked_quantity_total, :integer
  end
end
