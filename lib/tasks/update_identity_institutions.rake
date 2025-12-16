task update_identity_institutions: :environment do
  begin
    puts "Updating identities institution field..."
    pg = ProgressBar.new(Identity.count)
    Identity.find_each do |identity|
      institution_name = identity.professional_org_lookup('institution')
      if institution_name && identity.institution != institution_name
        identity.update_column(:institution, institution_name)
      end
      pg.increment!
    end
    puts "Identities institution field updated successfully."
  rescue => e
    puts "Error occurred: #{e.message}"
  end
end
