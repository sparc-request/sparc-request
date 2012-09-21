class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.integer :service_request_id
      t.integer :service_id
      t.decimal :charge_amount, :precision => 12, :scale => 4

      t.timestamps
    end

    add_index :charges, :service_request_id
  end
end
