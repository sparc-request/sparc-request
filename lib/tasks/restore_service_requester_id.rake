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

namespace :data do 
  desc "Restore service_requester_id"
  task :restore_service_requester_id => :environment do
    # Finding all SSRs without a service_requester_id that are linked to an actual protocol
    puts "Finding all SSRs that need their service_requester_id restored:"
    puts "Total SSRs needing service_requester_id updated:"
    puts SubServiceRequest.where(service_requester_id: nil).where.not(protocol_id: nil).count
    puts "SSR IDs:"
    # Finding all SSRs without a service_requester_id that are linked to an actual protocol
    CSV.open("tmp/ssrs_whose_service_requester_id_has_been_restored.csv", "wb") do |csv|
      csv << ["SSR ID"]
      SubServiceRequest.where(service_requester_id: nil).where.not(protocol_id: nil).each do |ssr|
        user_id = AuditRecovery.where(auditable_id: ssr.id, auditable_type: 'SubServiceRequest', action:  'create')
        if user_id.present?
          puts ssr.id
          csv << [ssr.id]
          ssr.update_attribute(:service_requester_id, user_id.first.user_id)
        end
      end
      puts "The Service Requester ID has been restored for the above ssrs."
    end
  end
end