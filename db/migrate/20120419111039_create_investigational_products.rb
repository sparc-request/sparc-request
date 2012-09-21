class CreateInvestigationalProducts < ActiveRecord::Migration
  def change
    create_table :investigational_products do |t|
      t.integer :protocol_id
      t.string :ind_number
      t.boolean :ind_on_hold
      t.string :ide_number

      t.timestamps
    end

    add_index :investigational_products, :protocol_id
  end
end
