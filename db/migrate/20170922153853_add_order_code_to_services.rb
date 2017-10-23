class AddOrderCodeToServices < ActiveRecord::Migration[5.1]
  def change
    add_column :services, :order_code, :string, after: :organization_id
  end
end
