class ChangeIsHispanicColumnInIdentities < ActiveRecord::Migration[5.2]
  def change
    add_column :identities, :ethnicity, :string
    
    Identity.where(is_hispanic: true).update_all(ethnicity: 'hispanic')
    Identity.where(is_hispanic: false).update_all(ethnicity: 'non_hispanic') 

    remove_column :identities, :is_hispanic
  end
end
