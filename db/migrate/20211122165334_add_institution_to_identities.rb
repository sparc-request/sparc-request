class AddInstitutionToIdentities < ActiveRecord::Migration[5.2]
  def change
    add_column :identities, :institution, :text
    add_index :identities, :institution, :length => { :institution => 55 }

    Identity.reset_column_information

    progress_bar = ProgressBar.new(Identity.count)
    Identity.find_each do |identity|
      identity.institution = identity.professional_org_lookup('institution')
      identity.save(validate: false)
      progress_bar.increment!
    end

  end
end
