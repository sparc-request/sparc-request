namespace :data do
  desc "Give user a role for protocols"
  task :give_user_role_for_protocols => :environment do |t|
    protocol_ids = []
    CSV.foreach("tmp/april_turner.csv", :headers => true) do |row|
      protocol_ids << row['SPARC']
    end

    count = 0
    ActiveRecord::Base.transaction do
      protocol_ids.each do |id|
        ProjectRole.create(:protocol_id => id, :identity_id => 42251, :role => "general-access-user", :project_rights => "request")
        count += 1
      end
    end

    puts "There were #{protocol_ids.count} protocol id's and there were #{count} roles created."
  end
end