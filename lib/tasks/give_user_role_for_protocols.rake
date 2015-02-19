namespace :data do
  desc "Give user a role for protocols"
  task :give_user_role_for_protocols => :environment do |t|
    count = 0
    ActiveRecord::Base.transaction do
      CSV.foreach("tmp/user_import.csv", :headers => true) do |row|
        # example CSV   1234, 5678, 'general-access-user', 'request'
        ProjectRole.create :protocol_id => row['Protocol ID'], 
                           :identity_id => row['Identity ID'], 
                           :role => row['Role'], 
                           :project_rights => row['Project Right']
        count += 1
      end
    end

    puts "There were #{protocol_ids.count} protocol id's and there were #{count} roles created."
  end
end
