class AddEapIdToServices < ActiveRecord::Migration
  def change
    add_column :services, :eap_id, :string
  end
end
