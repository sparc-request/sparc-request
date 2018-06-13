class AddProtocolIdAndServiceIdToAdminRates < ActiveRecord::Migration[5.2]
  def change
    add_reference :admin_rates, :protocol, foreign_key: true, after: :line_item_id, type: :integer
    add_reference :admin_rates, :service, foreign_key: true, after: :protocol_id, type: :integer
  end
end
