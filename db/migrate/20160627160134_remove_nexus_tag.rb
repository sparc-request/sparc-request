class RemoveNexusTag < ActiveRecord::Migration
  def change
  	Tag.where(name: 'ctrc_clinical_services').destroy_all
  end
end
