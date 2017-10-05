class AddUseDefaultStatusesColumnToOrgs < ActiveRecord::Migration[5.1]
  def change
    add_column :organizations, :use_default_statuses, :boolean, default: true
    Organization.all.each do |org|
      org.update(use_default_statuses: false) if org.available_statuses.any? || org.parent.available_statuses.any?
    end
  end
end
