namespace :mysql do
  desc 'execute a SQL command. Usage: rake db:execute SQL=""'
  task :execute => :environment do
    ActiveRecord::Base.establish_connection( (ENV['ENV'] || Rails.env).to_sym)
    ActiveRecord::Base.connection.execute( ENV['SQL'].to_s ).each { |hash| p hash }
  end

  desc 'Update values in settings table for development. Useful if you restore production database'
  task :dev_settings => :environment do
    Setting.set_value!( 'admin_mail_to','admin@example.com')
    Setting.set_value!( 'clinical_work_fulfillment_url','http://localhost:4000')
    Setting.set_value!( 'contact_us_cc',nil)
    Setting.set_value!( 'contact_us_mail_to','admin@example.com')
    Setting.set_value!( 'dashboard_link','/dashboard')
    Setting.set_value!( 'default_mail_to','admin@example.com')
    Setting.set_value!( 'feedback_mail_to','admin@example.com')
    Setting.set_value!( 'header_link_2_dashboard','http://localhost:3000/dashboard')
    Setting.set_value!( 'header_link_2_proper','http://localhost:3000/')
    Setting.set_value!( 'host','localhost:3000')
    Setting.set_value!( 'navbar_links',{"sparc_catalog"=>["SPARCCatalog", "http://localhost:3000/catalog_manager"], "sparc_dashboard"=>["Dashboard", "http://localhost:3000/dashboard"], "sparc_fulfillment"=>["SPARCFulfillment", "http://localhost:4000"], "sparc_request"=>["SPARCRequest", "http://localhost:3000/"], "sparc_report"=>["SPARCReport", "http://localhost:3000/reports"],"sparc_forms"=>["SPARCForms","http://localhost:3000/surveyor/responses"]}.to_json)
    Setting.set_value!( 'new_user_cc','admin@example.com')
    Setting.set_value!( 'remote_service_notifier_host','localhost:4000')
    Setting.set_value!( 'remote_service_notifier_password','betterthanruby')
    Setting.set_value!( 'remote_service_notifier_path','/v1/notifications.json')
    Setting.set_value!( 'remote_service_notifier_protocol','http')
    Setting.set_value!( 'remote_service_notifier_username','javais')
    Setting.set_value!( 'root_url','http://localhost:3000')
    Setting.set_value!( 'send_emails_to_real_users','false')
    Setting.set_value!( 'site_admins','["admin@example.com"]')
    Setting.set_value!( 'system_satisfaction_survey_cc','admin@example.com')
    Setting.set_value!( 'use_ldap','true')
    Setting.set_value!( 'use_shibboleth_only','false')
    Setting.set_value!( 'wkhtmltopdf_location',`which wkhtmltopdf`)
  end

  desc 'Backup database by mysqldump'
  task :backup => :environment do
    directory = File.join(Rails.root, 'db', 'backup')
    FileUtils.mkdir directory unless File.exists?(directory)
    require 'yaml'
    db = YAML::load( File.open( File.join(Rails.root, 'config', 'database.yml') ) )[ Rails.env ]
    file = File.join( directory, "#{Rails.env}_#{DateTime.now.to_s}.sql" )
    p command = "mysqldump --opt --skip-add-locks -u #{db['username']} -p#{db['password']} -h #{db['host']} #{db['database']} | gzip > #{file}.gz"
    exec command
  end

  desc "restore most recent mysqldump (from db/backup/*.sql.*) into the current environment's database."
  task :restore => :environment do |name|
    unless Rails.env.development?
      puts "Are you sure you want to import into #{Rails.env}?! [y/N]"
      return unless STDIN.gets =~ /^y/i
    end

    db = YAML::load( File.open( File.join(Rails.root, 'config', 'database.yml') ) )[ Rails.env ]
    directory = File.join( Rails.root, 'db', 'backup')
    wildcard  = File.join( directory, ENV['FILE'] || "#{ENV['FROM']}*.sql.*" )
    puts file = `ls -t #{wildcard} | head -1`.chomp  # default to file, or most recent ENV['FROM'] or just plain most recent

    raise "No backup file found" unless File.exist?(file)

    host = db['host'] || 'localhost'

    puts "please wait, this may take a minute or two..."
    if file =~ /\.gz(ip)?$/
      exec "gunzip < #{file} | mysql  -u #{db['username']} -p#{db['password']} -h #{host} #{db['database']}"
    else
      exec "mysqlimport -u #{db['username']} -p#{db['password']} #{db['database']} #{file}"
    end
  end
end
