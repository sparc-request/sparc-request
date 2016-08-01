class DisableChildrenOfDisabledOrganizations < ActiveRecord::Migration
  def change
    organizations = Organization.where(is_available: false)

    organizations.each do |org|
      org.update_descendants_availability("false")
    end
  end
end
