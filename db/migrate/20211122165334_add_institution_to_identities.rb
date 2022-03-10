class AddInstitutionToIdentities < ActiveRecord::Migration[5.2]
  def change
    add_column :identities, :institution, :text
    add_index :identities, :institution, :length => { :institution => 55 }

    Identity.reset_column_information

    Identity.all.each do |identity|
      identity.institution = identity.professional_org_lookup('institution')
      identity.save(validate: false)
    end

  end
end
