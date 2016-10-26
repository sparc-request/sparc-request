class RenameIdeNumberToInvDeviceNumber < ActiveRecord::Migration
  def up
    rename_column :investigational_products_info, :ide_number, :inv_device_number
    add_column :investigational_products_info, :exemption_type, :string, default: ""

    InvestigationalProductsInfo.find_each do |inv|
      if inv.inv_device_number.present?
        inv.update(exemption_type: "ide")
      end
    end
  end

  def down
    rename_column :investigational_products_info, :inv_device_number, :ide_number
    remove_column :investigational_products_info, :exemption_type
  end
end
