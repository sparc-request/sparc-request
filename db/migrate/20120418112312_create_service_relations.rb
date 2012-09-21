class CreateServiceRelations < ActiveRecord::Migration
  def change
    create_table :service_relations do |t|
      t.integer :service_id
      t.integer :related_service_id
      t.boolean :optional

      t.timestamps
    end

    add_index :service_relations, :service_id
  end
end
