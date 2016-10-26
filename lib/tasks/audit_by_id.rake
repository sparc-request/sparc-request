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

namespace :data do 
  desc "Describe audits when provided with a porotocol id"
  task :audit_by_id => :environment do 
    $indicator = nil

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def status auditable_type, auditable_id
      puts ""
      print "Retrieving #{auditable_type} - #{auditable_id} audit data"
    end

    def show_processing_indicator
      $indicator = Thread.new do
        loop do
          print "."
          sleep 0.2
        end
      end.run
    end

    def hide_processing_indicator
      $indicator.kill
      puts ""
    end

    def audits_for x_auditable_type, x_auditable_id
      status x_auditable_type, x_auditable_id
      show_processing_indicator
      all_audits = AuditRecovery.where(:auditable_id => x_auditable_id, :auditable_type => x_auditable_type) #audits for protocol
      hide_processing_indicator

      child_audits = []
      x_auditable_type.constantize.reflect_on_all_associations.map{|assoc| assoc.name.to_s.classify}.each do |auditable_type|
        next if auditable_type == 'Audit'
        print "Searching #{auditable_type} audit data for #{x_auditable_type} - #{x_auditable_id}"
        show_processing_indicator
        child_audits.concat AuditRecovery.where(:auditable_type => auditable_type)
                                         .where("audited_changes like '%#{x_auditable_type.underscore}_id: #{x_auditable_id}%' OR 
                                                 audited_changes like '%#{x_auditable_type.underscore}_id:\n- \n- #{x_auditable_id}%'")
        hide_processing_indicator
      end

      ids_and_types = Hash.new {|this_hash, nonexistent_key| this_hash[nonexistent_key] = []}
      child_audits.each do |audit|
        ids_and_types[audit.auditable_type] << audit.auditable_id
      end

      ids_and_types.each do |auditable_type, ids|
        ids.uniq!

        ids.each do |id|
          all_audits.concat audits_for(auditable_type, id)
        end
      end

      all_audits
    end

    model = prompt "Enter the model you would like to investigate (eg. Protocol): "
    record_id = prompt "Enter the specific record id you would like to investigate (eg. 7356): "
    audits = audits_for model, record_id

    puts "Sorting audits"
    audits.sort_by!(&:id)
    puts "Removing duplicate audits"
    audits.uniq_by!(&:id)

    #{"StudyType" => [1, 2, 3, 3, 3], "ResearchTypeInfo" => [1, 3, 4]}
  
    CSV.open("tmp/audit_by_id_data_protocol_id_#{record_id}.csv","wb") do |csv|
     csv << ["Model: #{model}", "Record ID: #{record_id}"]
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
