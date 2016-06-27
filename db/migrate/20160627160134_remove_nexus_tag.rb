class RemoveNexusTag < ActiveRecord::Migration
  def change
  	Tag.where(name: 'ctrc_clinical_services').first.destroy
  end
end
