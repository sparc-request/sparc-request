class AddOverriddenToSubsidies < ActiveRecord::Migration
  def change
    add_column :subsidies, :overridden, :boolean
  end
end
