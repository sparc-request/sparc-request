class ChangeColorDefaultOnOrganization < ActiveRecord::Migration
  def change
    change_column :organizations, :css_class, :string, :default => ""
  end
end
