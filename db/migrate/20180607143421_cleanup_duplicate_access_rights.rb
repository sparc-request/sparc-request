class CleanupDuplicateAccessRights < ActiveRecord::Migration[5.2]
  def change
    CatalogManager.find_each do |catalog_manager|
      catalog_manager.identity.catalog_managers.includes(:organization).where.not(id: catalog_manager.id).each do |cm|
        if cm.organization.parents.include?(catalog_manager.organization)
          puts '#' * 50
          puts "Removing duplicate catalog manager lower access right: Catalog Manager ID: #{cm.id}, Identity ID: #{cm.identity.id}"
          cm.destroy
        end
      end
    end
    SuperUser.find_each do |super_user|
      super_user.identity.super_users.includes(:organization).where.not(id: super_user.id).each do |su|
        if su.organization.parents.include?(super_user.organization)
          puts '#' * 50
          puts "Removing duplicate super user lower access right: Super User ID: #{su.id}, Identity ID: #{su.identity.id}"
          su.destroy
        end
      end
    end
  end
end
