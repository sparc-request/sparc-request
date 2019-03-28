# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

namespace :sparc do
  task :bootstrap => ["db:create", :environment] do

    unless table_created?("organizations") && table_created?("identities") && table_created?("catalog_managers")
      puts "Creating database schema"
      Rake::Task["db:schema:load"].invoke
      Institution.reset_column_information
      Identity.reset_column_information
      CatalogManager.reset_column_information
    end

    if Institution.count == 0
      puts "Creating institutions"
      Institution.create(name: 'MUHA', abbreviation: 'muha', is_available: true)
      Institution.create(name: 'MUSCP', abbreviation: 'muscp', is_available: true)
      Institution.create(name: 'MUSC', abbreviation: 'musc', is_available: true)
    end

    if ProfessionalOrganization.count == 0
      puts "Creating professional organizations"
      Institution.all.each do |inst|
        ProfessionalOrganization.create(name: inst.name, org_type: 'institution')
      end
    end

    if Identity.count == 0 && ProfessionalOrganization.count > 0
      puts "Creating admin user"
      admin = Identity.create({
	ldap_uid: "admin",
	email: "admin@example.com",
	first_name: "Admin",
	last_name: "Admin",
	password: "adminadmin",
	password_confirmation: "adminadmin",
	catalog_overlord: true,
	approved: true,
	professional_organization_id: ProfessionalOrganization.where(org_type: 'institution').first.id
      })
    else
      admin = Identity.where(catalog_overlord: true).first
    end

    if CatalogManager.count == 0 && admin
      puts "Creating catalog managers"
      Institution.all.each do |inst|
        CatalogManager.create(organization_id: inst.id, identity_id: admin.id)
      end
    end

    if database_exists?
      puts "Running migrations"
      Rake::Task["db:migrate"].invoke
    end

    if Setting.count == 0
      puts "Populating settings table"
      SettingsPopulator.new().populate
    end
  end

  def database_exists?
    ActiveRecord::Base.connection
  rescue ActiveRecord::NoDatabaseError
    false
  else
    true
  end

  def table_created?(table)
    ActiveRecord::Base.connection.tables.include?(table)
  end
end
