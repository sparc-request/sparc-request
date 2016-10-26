# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# ----------------------------------------------------------------------
# Script to initially set up a database when setting up a new instance
# of SPARC
#
# Run it like this:
# $ rails r initial_cm_creation
# ----------------------------------------------------------------------

require 'active_record'
require 'mysql2'
require 'highline'
require 'highline/import'

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

  args = { catalog_overlord: true, approved: true }
  args[:ldap_uid]   = ask("Identity UID (login/username): ")
  args[:email]      = ask("Identity Email: ")
  args[:first_name] = ask("Identity First Name: ")
  args[:last_name]  = ask("Identity Last Name: ")
  args[:password]   = ask("Identity password: ") { |q| q.echo = '*' }
  args[:password_confirmation] = ask("Confirm password: ") { |q| q.echo = '*' }

  print_breakline
  puts "Creating Identity..."
  print_breakline

  if identity = Identity.find_by_ldap_uid(args[:ldap_uid]) then
    identity.update_attributes(args)
  else
    identity = Identity.create(args)
  end

  print_breakline

  if identity.errors.size > 0 then
    puts "FAILED: #{identity.errors.inspect}"
    gets
    return
  end

  choose do |menu|
    menu.prompt = "Is this user a catalog manager for an Institution?"
    menu.choice(:yes) { create_catalog_manager(identity) }
    menu.choice(:no) { system("clear"); opening_menu() }
  end
end

def create_catalog_manager identity=nil
  while identity.nil?
    system "clear"
    print_breakline
    puts "Please select an Identity to associate:"
    print_breakline
    Identity.all.each do |iden|
      puts "#{iden.id}. #{iden.first_name} #{iden.last_name} #{iden.email}"
    end
    # identity = Identity.find(gets.chomp)
    # ldap_uid = ask("Enter ldap uid: ")
    # identity = Identity.find_by_ldap_uid(ldap_uid)
    # if not identity then
    #   puts "Identity not found.  Press <Enter>"
    #   gets
    # end
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
