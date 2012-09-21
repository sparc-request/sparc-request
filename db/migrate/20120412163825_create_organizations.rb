class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :type
      t.string :name
      t.integer :order
      t.string :css_class
      t.text :description
      t.string :obisid
      t.integer :parent_id
      t.string :abbreviation
      t.text :ack_language
      t.boolean :process_ssrs
      t.boolean :is_available

      t.timestamps
    end

    add_index :organizations, :obisid
    add_index :organizations, :parent_id
    add_index :organizations, :is_available
  end
end
