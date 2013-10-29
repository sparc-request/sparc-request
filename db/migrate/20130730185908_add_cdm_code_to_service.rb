class AddCdmCodeToService < ActiveRecord::Migration
  def change
  	add_column :services, :cdm_code, :string
  	add_column :services, :send_to_epic, :boolean, :default => false
  end
end
