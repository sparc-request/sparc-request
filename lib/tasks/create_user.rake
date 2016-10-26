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

  puts "This task will create a user with all rights for a given organization, for testing and development purposes."
  password = prompt "Enter a password for your new user that is 6 charaters or longer: "
  while password.size < 6
    password = prompt "Enter a password for your new user that is 6 charaters or longer: "
  end
  
  list_orgs

  puts ""
  puts ""
  puts "The ldap uid is defaulted to 'juan@musc.edu'"
  puts ""

  sparc_id = prompt "Enter the id of the above organization you want sparc rights for: "

  fulfillment = prompt "Do you need rights in sparc fulfillment? (Yes/No): "
  puts ""
  puts ""

  if fulfillment == 'Yes'
    cwf_id = prompt "Enter the id of the above organization you want sparc fulfillment rights for: "
    puts ""
    puts ""
    desired_fulfillment_organization = Organization.find(cwf_id.to_i)
  end

  desired_sparc_organization = Organization.find(sparc_id.to_i)

  puts "You have indicated that you wish to have sparc rights for #{desired_sparc_organization.name}"
  if fulfillment == 'Yes'
    puts "and fulfillment rights for #{desired_fulfillment_organization.name}."
  end
  puts ""
  puts ""
  continue = prompt "Is this correct? (Yes/No): "

  if continue == "Yes"
    puts "Creating Juan..."
    identity = Identity.create(:ldap_uid => 'juan@musc.edu',
                             :email => 'juan@musc.edu',
                             :last_name => 'Castillo',
                             :first_name => 'Juan',
                             :phone => '555-555-5555',
                             :catalog_overlord => 1,
                             :password => "#{password}",
                             :password_confirmation => "#{password}",
                             :approved => 1 )
    identity.save
    CatalogManager.create(:identity_id => identity.id, :organization_id => sparc_id.to_i, :edit_historic_data => 1)
    SuperUser.create(:identity_id => identity.id, :organization_id => sparc_id.to_i)

    if fulfillment == 'Yes'
      ClinicalProvider.create(identity_id: identity.id, organization_id: cwf_id.to_i)
    end
  else
    puts "Task aborted"
  end
end
