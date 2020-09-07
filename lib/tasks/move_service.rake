# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

desc 'Moves a Service or Services to another Organization'

task move_service: :environment do
  ActiveRecord::Base.transaction do
    services = Service.find(34054, 34055, 34056)
    destination_org = Organization.find(350)

    doxy_ssrs_created = CSV.open("tmp/doxy_ssrs.csv", "w")
    doxy_ssrs_created << ['Original SSR', 'New SSR']

    services.each do |service|

      puts "Moving `#{service.name}` to `#{destination_org.name}`"

      sub_service_requests = service.sub_service_requests

      sub_service_requests.each do |ssr|
        protocol = ssr.protocol
        # Just in case we have any first_draft SSRs with no protocol
        if protocol
          if just_line_items_for_our_services?(ssr, services)
            # Don't really need to move anything. Just move the SSR
            # to the new organization.
            puts "Nothing to move for SSR #{ssr.id}."
            ssr.organization_id = destination_org.id
            ssr.save(validate: false)
          else
            # # We know now we have a mixed bag and will need a new sub service request
            # # for the line items belonging to our service. We'll leave the other line items
            # # on the original SSR
            puts "New SSR created."
            new_ssr = SubServiceRequest.new(
                organization_id:         destination_org.id,
                status:                  ssr.status,
                service_request_id:      ssr.service_request_id,
                owner_id:                ssr.owner_id,
                ssr_id:                  (sprintf '%04d', protocol.next_ssr_id),
                in_work_fulfillment:     ssr.in_work_fulfillment,
                service_requester_id:    ssr.service_requester_id,
                submitted_at:            ssr.submitted_at,
                protocol_id:             ssr.protocol_id,
                imported_to_fulfillment: ssr.imported_to_fulfillment,
                synch_to_fulfillment:    ssr.synch_to_fulfillment
              )

            new_ssr.save(validate: false)
            protocol.next_ssr_id = protocol.next_ssr_id + 1
            protocol.save(validate: false)
            new_ssr.update_org_tree
            if ssr.in_work_fulfillment || ssr.imported_to_fulfillment
              puts "-" * 100
              puts "This ssr is in fulfillment. Old = #{ssr.id} new = #{new_ssr.id}"
              puts "-" * 100
              doxy_ssrs_created << [ssr.id, new_ssr.id]
            end

            ssr.line_items.each do |line_item|
              if services.include?(line_item.service)
                line_item.sub_service_request_id = new_ssr.id
                line_item.save(validate: false)
              end
            end
          end
        end
      end
      service.update!(organization_id: destination_org.id)
    end
  end
end

def just_line_items_for_our_services?(ssr, services)
  ssr.line_items.each do |line_item|
    if !services.include?(line_item.service)
      return false
    end
  end

  return true
end