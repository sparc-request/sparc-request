require 'active_record'
require 'mysql2'

def opening_message
  print_breakline
  puts "Welcome to the SPARC Request Automated Initial Catalog Manager Identity and Institution Generation Tool!"
end

def opening_menu
  print_breakline
  puts "Please choose an option:"
  puts "1. Create an Institution"
  puts "2. Create an Identity/Catalog Manager"
  puts "3. Associate an Identity with an Institution (Catalog Manager)"
  puts "4. Return to console"
  print_breakline
  answer = gets.chomp
  case answer
  when "1"
    create_institution()
  when "2"
    create_identity()
  when "3"
    create_catalog_manager()
  when "4"

  else
    puts "#{answer} is not a valid input, please try again"
    opening_menu
  end

end

def create_institution
  system "clear"
  print_breakline
  puts "Please enter the following information:"
  print_breakline
  puts "Institution Name:"
  institution_name = gets.chomp
  puts "Institution Abbreviation:"
  institution_abbreviation = gets.chomp
  print_breakline
  puts "Creating Institution..."
  print_breakline
  Institution.create({name: institution_name, abbreviation: institution_abbreviation, is_available: true})
  print_breakline
  puts "Institution has been created."
  gets
  system "clear"
  opening_menu()
end

def create_identity
  system "clear"
  print_breakline
  puts "Please enter the following information:"
  print_breakline
  args = {catalog_overlord: true, approved: true}
  puts "Identity UID (login/username):"
  args[:ldap_uid] = gets.chomp
  puts "Identity Email:"
  args[:email] = gets.chomp
  puts "Identity First Name:"
  args[:first_name] = gets.chomp
  puts "Identity Last Name:"
  args[:last_name] = gets.chomp
  puts "Identity Password:"
  args[:password] = gets.chomp
  puts "Confirm Password:"
  args[:password_confirmation] = gets.chomp
  print_breakline
  puts "Creating Identity..."
  print_breakline
  identity = Identity.create(args)
  print_breakline
  puts "Is this user a catalog manager for an Institution?"
  puts "1. Yes"
  puts "2. No"
  print_breakline
  answer = gets.chomp
  case answer
  when "1"
    create_catalog_manager(identity)
  else
    system "clear"
    opening_menu()
  end
end

def create_catalog_manager identity=nil
  if identity.nil?
    system "clear"
    print_breakline
    puts "Please select an Identity to associate:"
    print_breakline
    Identity.all.each do |iden|
      puts "#{iden.id}. #{iden.first_name} #{iden.last_name} #{iden.email}"
    end
    identity = Identity.find(gets.chomp)
  end
  print_breakline
  puts "Please select an institution to attach this user to:"
  Institution.all.each do |inst|
    puts "#{inst.id}. #{inst.name}"
  end
  selected_institution = Institution.find(gets.chomp)
  if selected_institution
    puts "Associating identity:"
    print_breakline
    CatalogManager.create(organization_id: selected_institution.id, identity_id: identity.id)
    print_breakline
    puts "Identity has been associated."
    gets
    system "clear"
    opening_menu()
  else
    puts "Invalid institution (please press enter)"
    gets
    create_catalog_manager(identity)
  end
end

def print_breakline
  puts "########################################################################################################"
end

def run_initial_setup
  system "clear"
  opening_message
  opening_menu
end