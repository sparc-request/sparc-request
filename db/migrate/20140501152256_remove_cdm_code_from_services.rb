class RemoveCdmCodeFromServices < ActiveRecord::Migration
  def change
    remove_column :services, :cdm_code
  end
end
