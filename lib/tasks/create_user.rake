task :create_user => :environment do

  def prompt(*args)
      print(*args)
      STDIN.gets.strip
  end
    
  def list_orgs
    puts "#"*50
    institutions = Institution.order(:name)
    institutions.each do |inst|
      puts "- #{inst.name} => #{inst.id}"

      inst.providers.order(:name).each do |prov|
        puts "--- #{prov.name} => #{prov.id}"

        prov.programs.order(:name).each do |prog|
          puts "----- #{prog.name} => #{prog.id}"

          prog.cores.order(:name).each do |core|
            puts "------- #{core.name} => #{core.id}"
          end
        end
      end

      puts ""
    end
    puts "#"*50
  end

  users = Identity.all
  puts "This task will create a user with all rights for a given organization, for testing and development purposes."
  user_name = prompt "Enter a user name: "
  users.each do |user|
    while user.ldap_uid == user_name
      user_name = prompt "That user already exists, please enter another: "
    end
  end

  list_orgs

  puts ""
  puts ""
  puts "The password is defaulted to 'password'"
  puts ""
  id = prompt "Enter the id of the above organization you want rights for: "
  desired_organization = Organization.find(id.to_i)
  continue = prompt "You have indicated that you wish to have rights for #{desired_organization.name}, do you want to proceed? (Yes/No) "
  if continue == "Yes"
    puts "Creating #{user_name}..."
    identity = Identity.create(:ldap_uid => "#{user_name}", 
                             :email => "#{user_name}@gmail.com", 
                             :last_name => 'Castillo', 
                             :first_name => "#{user_name.capitalize}", 
                             :phone => '555-555-5555', 
                             :catalog_overlord => 1,
                             :password => 'password',
                             :password_confirmation => 'password',
                             :approved => 1 )
    identity.save
    CatalogManager.create(:identity_id => identity.id, :organization_id => id.to_i, :edit_historic_data => 1)
    SuperUser.create(:identity_id => identity.id, :organization_id => id.to_i)
  else
    puts "Task aborted"
  end
end
