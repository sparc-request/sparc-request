class RemoveIsCtrcFlagFromOrganization < ActiveRecord::Migration
  def up
    Organization.all.each do |org|
      if org.is_ctrc?
        org.tag_list = "ctrc"
        org.save
      end
    end

    remove_column :organizations, :is_ctrc
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
