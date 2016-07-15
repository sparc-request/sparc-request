class AddDefaultSubsidyAndInformation < ActiveRecord::Migration
  def change
  	add_column :subsidy_maps, :default_percentage, :float, default: 0
  	add_column :subsidy_maps, :instructions, :text
  end
end
