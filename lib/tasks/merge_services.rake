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

desc 'Merge an old service into a new service (example only).'

task merge_services: :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  ActiveRecord::Base.transaction do
    
    master_service_id = (prompt "Enter the master service id: ").to_i
    old_service_id = (prompt "Enter the id of the service to be merged and deleted: ").to_i

    puts "You have entered #{old_service_id} for the old service and #{master_service_id}"
    puts "for the master service."
    continue = prompt("Is this correct and is it ok to continue? (y/n): ")
    if continue == 'y'
      puts "Merging service"
      merge_service(old_service_id, master_service_id)
    else
      puts "Exiting task..."
    end
  end # ActiveRecord::Base.transaction
end # task

def merge_service(old_service_id, master_service_id)
  old_service = Service.find(old_service_id)
  master_service = Service.find(master_service_id)
  organization = master_service.process_ssrs_organization
  dest_org_process_ssrs = master_service.organization.process_ssrs_parent
  puts "Merging Service #{old_service.id} into #{master_service.id} belonging to Org ##{dest_org_process_ssrs.id}"

  old_service.line_items.each do |line_item|
    ssr = line_item.sub_service_request
    line_item.service_id = master_service_id
    line_item.save(validate: false)
    ssr.organization = organization
    ssr.save(validate: false)
  end

  old_service.delete
end
