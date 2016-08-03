class EapIdShouldBeVarchar < ActiveRecord::Migration
  def change
    change_column :services, :eap_id, :string
  end
end
