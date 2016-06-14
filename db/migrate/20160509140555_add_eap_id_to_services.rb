class AddEapIdToServices < ActiveRecord::Migration
  def change
    add_column :services, :eap_id, :integer
  end
end
