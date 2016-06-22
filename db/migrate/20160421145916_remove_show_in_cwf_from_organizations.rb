class RemoveShowInCwfFromOrganizations < ActiveRecord::Migration
  def change
    remove_column :organizations, :show_in_cwf, :boolean
  end
end
