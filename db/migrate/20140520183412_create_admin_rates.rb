class CreateAdminRates < ActiveRecord::Migration
  def change
    create_table :admin_rates do |t|

      t.timestamps
    end
  end
end
