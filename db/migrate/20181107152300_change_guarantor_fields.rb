class ChangeGuarantorFields < ActiveRecord::Migration[5.2]
  def change
    add_column :protocols, :guarantor_email, :string
    remove_column :protocols, :guarantor_fax
    remove_column :protocols, :guarantor_address
    remove_column :protocols, :guarantor_city
    remove_column :protocols, :guarantor_state
    remove_column :protocols, :guarantor_zip
    remove_column :protocols, :guarantor_county
    remove_column :protocols, :guarantor_country
  end
end
