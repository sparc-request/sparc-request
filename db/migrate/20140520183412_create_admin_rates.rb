class CreateAdminRates < ActiveRecord::Migration
  def change
    create_table :admin_rates do |t|
      t.belongs_to :line_item
      t.integer :admin_cost
      t.timestamps
    end
  end
end
