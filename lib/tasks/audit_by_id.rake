namespace :data do 
  desc "Describe audits when provided with a porotocol id"
  task :audit_by_id => :environment do 
    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def status auditable_type, auditable_id
      puts "Pulling #{auditable_type} - #{auditable_id} audit data"
    end

    def audits_for x_auditable_type, x_auditable_id
      status x_auditable_type, x_auditable_id
      all_audits = AuditRecovery.where(:auditable_id => x_auditable_id, :auditable_type => x_auditable_type) #audits for protocol

      child_audits = []
      x_auditable_type.constantize.reflect_on_all_associations.map{|assoc| assoc.name.to_s.classify}.each do |auditable_type|
        next if auditable_type == 'Audit'
        puts "Polling #{auditable_type} audit data for #{x_auditable_type} - #{x_auditable_id}"
        child_audits.concat AuditRecovery.where(:auditable_type => auditable_type).where("audited_changes like '%#{x_auditable_type.underscore}_id: #{x_auditable_id}%' OR 
                                                                                          audited_changes like '%#{x_auditable_type.underscore}_id:\n- \n- #{x_auditable_id}%'")
      end

      ids_and_types = Hash.new {|this_hash, nonexistent_key| this_hash[nonexistent_key] = []}
      child_audits.each do |audit|
        ids_and_types[audit.auditable_type] << audit.auditable_id
      end

      ids_and_types.each do |auditable_type, ids|
        ids.uniq!

        ids.each do |id|
          status auditable_type, id
          all_audits.concat AuditRecovery.where(:auditable_id => id, :auditable_type => auditable_type)
          all_audits.concat audits_for(auditable_type, id)
        end
      end

      all_audits
    end

    answer = prompt "Enter the protocol id of the study you would like to investigate: "
    audits = audits_for 'Protocol', answer

    puts "Sorting audits"
    audits.sort_by!(&:id)
    puts "Removing duplicate audits"
    audits.uniq_by!(&:id)

    #{"StudyType" => [1, 2, 3, 3, 3], "ResearchTypeInfo" => [1, 3, 4]}
  
    CSV.open("audit_by_id_data_protocol_id_#{answer}.csv","wb") do |csv|
     csv << ["PID: #{answer}"]
     csv << ["Audit ID", "Created At", "User Display Name", "User ID", "Auditable Type", "Auditable ID", "Action", "Changes"]
     audits.each do |e|
       user = Identity.find(e.user_id) rescue nil
       csv << [e.id, e.created_at, user.try(:display_name), e.user_id, e.auditable_type, e.auditable_id, e.action, e.audited_changes]
     end
    end 
  end
end 



        


#csv << [e.created_at, e.user_id, e.user_type, e.remote_address,e.auditable_type, e.action, e.audited_changes]


   # AuditRecovery.where(:auditable_type => 'ServiceRequest').where("audited_changes like '%protocol_id => [ ,6371]%'")

#[
