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
