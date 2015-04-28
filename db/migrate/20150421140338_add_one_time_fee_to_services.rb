class AddOneTimeFeeToServices < ActiveRecord::Migration
  def change
    add_column :services, :one_time_fee, :boolean, :default => false
  end
end
