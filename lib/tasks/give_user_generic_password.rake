namespace :data do
  desc "Give user a generic password"
  task :give_user_generic_password => :environment do
    def header
      [
        "identity_id"
      ]
    end

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def get_file(error=false)
      puts "No import file specified or the file specified does not exist in db/imports" if error
      file = prompt "Please specify the file name to import from db/imports (must be a CSV, see db/imports/example.csv for formatting): "
      puts ""
      continue = prompt "Password of all users will be changed!  Press any key to continue or CTRL-C to exit"
      puts ""
      while file.blank? or not File.exists?(Rails.root.join("db", "imports", file))
        file = get_file(true)
      end

      file
    end

    begin
      file = get_file
      input_file = Rails.root.join('db', 'imports', file)
      count = 0
      CSV.foreach(input_file, :headers => true, :encoding => 'windows-1251:utf-8') do |row|
        id = row["identity_id"]
        i = Identity.find(id.to_i)
        password = Devise.friendly_token
        i.update_attributes(password: password,
                            password_confirmation: password)
        print i.ldap_uid
        print "  -  "
        puts password
        count += 1
      end
      puts ""
      puts "There were #{count} passwords successfully reset."
      puts ""
    end
  end
end
