class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :obisid
      t.string :name
      t.string :abbreviation
      t.integer :order
      t.text :description
      t.boolean :is_available
      t.decimal :service_center_cost, :precision => 12, :scale => 4
      t.string :cpt_code
      t.string :charge_code
      t.string :revenue_code
      t.integer :organization_id

      t.timestamps
    end

    add_index :services, :organization_id
    add_index :services, :is_available
    add_index :services, :obisid
  end
end
