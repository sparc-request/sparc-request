# Copyright © 2011-2016 MUSC Foundation for Research Development~
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
  desc "List out all destroyed line items for a given service and protocol id"
  task :audit_destroyed_line_items => :environment do
    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    protocol_id = prompt("Please enter a protocol_id: ")
    service_id = prompt("Please enter a service id: ")

    service_requests = ServiceRequest.where(:protocol_id => protocol_id.to_i)
    line_items = AuditRecovery.where("auditable_type = ? AND action = ?", "LineItem", "destroy")
    new_lis = []

    service_requests.each do |sr|
      sr.sub_service_requests.each do |ssr|
        line_items.each do |li|
          if (li[:audited_changes]["service_id"] == service_id.to_i) && (li[:audited_changes]["sub_service_request_id"] == ssr.id)
            new_lis << li
          end
        end
      end
    end

    new_lis.each do |li|
      deleter = Identity.find(li[:user_id])
      puts "Line item #{li[:auditable_id]} was deleted by #{deleter.full_name} on #{li[:created_at]}"
    end
  end
end
