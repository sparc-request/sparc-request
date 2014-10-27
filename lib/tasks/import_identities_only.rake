namespace :data do
  desc "Import identities (only) from CSV"
  task :import_identities_only, [:uid_domain] => :environment do |t, args|
    if args[:uid_domain]
        CSV.foreach("identities.csv", :headers => true) do |row|
          # uid, first name, last name, email, institution, department, college  
          if row[0] and row[1] and row[2] and row[3]
            uid = row[0] << args[:uid_domain]
            identity = Identity.where(:ldap_uid => uid).first
            if identity
              identity.update_attributes(first_name: row[1], last_name: row[2], email: row[3], institution: row[4], department: row[5], college: row[6]) 
              puts "updated " + uid 
            else
              identity = Identity.create :ldap_uid => uid, :first_name => row[1], :last_name => row[2], :email => row[3], 
                                          :institution => row[4], :department => row[5], :college => row[6],
                                          :password => Devise.friendly_token[0,20], :approved => true
              puts "imported " + uid
            end
          else
            if row[0]
              puts "Error: " + row[0] + " not imported because missing data"
            else 
              puts "Error: uid not specified"
            end            
          end
        end
    else
      puts "Error UID domain must be passed in as an argument"
    end    
  end
end

