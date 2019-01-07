class AddGuarantorFieldsToProtocol < ActiveRecord::Migration[5.2]
  def change
    add_column :protocols, :guarantor_contact, :string
    add_column :protocols, :guarantor_address, :text
    add_column :protocols, :guarantor_city, :string
    add_column :protocols, :guarantor_phone, :string
    add_column :protocols, :guarantor_state, :string
    add_column :protocols, :guarantor_zip, :string
    add_column :protocols, :guarantor_county, :string
    add_column :protocols, :guarantor_country, :string
    add_column :protocols, :guarantor_fax, :string
  end
end
