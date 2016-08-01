# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
namespace :data do
  desc "Give user a role for protocols"
  task :give_user_role_for_protocols => :environment do |t|

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    import_file = prompt "Enter the file to be imported: "
    raise 'Import file not found' if import_file.blank? or not File.exists?(import_file)

    count = 0
    ActiveRecord::Base.transaction do
      CSV.foreach(import_file, :headers => true) do |row|
        # example CSV   1234, 5678, 'general-access-user', 'request'
        ProjectRole.create(:protocol_id => row["PROTOCOL ID"], 
                           :identity_id => row["IDENTITY ID"], 
                           :role => row["ROLE"], 
                           :project_rights => row["PROJECT RIGHT"])
        count += 1
      end
    end

    puts "There were #{count} roles successfully created."
  end
end
