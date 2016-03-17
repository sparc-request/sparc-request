class ChangeDefaultsOnOrganization < ActiveRecord::Migration
  def change
    change_column :organizations, :process_ssrs, :boolean, :default => 0

    Organization.where(process_ssrs: nil).each do |org|
      org.process_ssrs = 0
      org.save
    end
  end
end
