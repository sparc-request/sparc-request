class RemoveCdmCode < ActiveRecord::Migration
  def up
    services = Service.where("cdm_code is not null and cdm_code != ''")

    services.each do |service|
      service.update_attribute(:charge_code, service.cdm_code)
    end

    remove_column :services, :cdm_code
  end

  def down
    add_column :services, :cdm_code
  end
end
