class CreateSubsidies < ActiveRecord::Migration
  def change
    create_table :subsidies do |t|
      t.integer :service_request_id
      t.integer :organization_id
      t.integer :pi_contribution

      t.timestamps
    end

    add_index :subsidies, :service_request_id
  end
end
