# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

desc 'Moves a Service to another Organization'

task :move_service, [:service_id, :organization_id] => :environment do |t, args|
  ActiveRecord::Base.transaction do
    service = Service.find(args[:service_id])
    dest_org = Organization.find(args[:organization_id])
    # service will now belong to SSR's with this organization:
    dest_org_process_ssrs = dest_org.process_ssrs_parent

    puts "Moving `#{service.name}` to `#{dest_org.name}`"

    puts "\nService requests and sub service requests affected:"

    service.service_requests.each do |sr|
      puts "Working on SRID: #{sr.id}"
      # SSR's that contain LineItems that need to be moved
      ssrs = sr.sub_service_requests.
        where.not(organization: dest_org_process_ssrs).
        joins(:line_items).
        where(line_items: { service_id: service.id })

      ssrs.each do |ssr|
        puts "Working on SSRID: #{ssr.id}"
        if ssr_contains_just_this_service?(ssr, service)
          # Don't really need to move anything. Just move the SSR
          # to another Organization.
          ssr.update!(organization_id: dest_org_process_ssrs.id)
          puts "SRID: #{sr.id} SSRID: #{ssr.id} (simple organization update)"
        else
          # Find a destination SSR for service. Use an existing one
          # or create one if necessary.
          dest_ssr_exists = true
          unless dest_ssr = ssr.service_request.sub_service_requests.find_by(organization: dest_org_process_ssrs, status: ssr.status)
            dest_ssr_exists = false
            dest_ssr = ssr.service_request.sub_service_requests.create(
              organization: dest_org_process_ssrs,
              status:       ssr.status
            )

            # Move over old SSR attributes.
            old_attributes = ssr.attributes
            # ! needed, since only it will return the _other_ attributes.
            copy_over_attributes = old_attributes.
              slice!(*%w(id ssr_id organization_id org_tree_display status))
            
            # fix 2 dates so that they are in the correct format for custom setters in the SSR model
            copy_over_attributes['requester_contacted_date'] = copy_over_attributes['requester_contacted_date'].blank? ? nil : copy_over_attributes['requester_contacted_date'].strftime('%m/%d/%Y')
            copy_over_attributes['consult_arranged_date'] = copy_over_attributes['consult_arranged_date'].blank? ? nil : copy_over_attributes['consult_arranged_date'].strftime('%m/%d/%Y')

            dest_ssr.assign_attributes(copy_over_attributes)
            dest_ssr.save(validate: false)
            dest_ssr.update_org_tree

            # Copy over past_statuses
            ssr.past_statuses.each do |ps|
              dest_ssr.past_statuses.create status: ps.status, date: ps.date, deleted_at: ps.deleted_at, changed_by_id: ps.changed_by_id, new_status: ps.new_status
            end
          end
          # Move LineItems.
          line_items_moved = []
          ssr.line_items.where(service: service).each do |li|
            li.update!(sub_service_request: dest_ssr)
            line_items_moved << li.id
          end

          puts "SRID: #{sr.id} Old SSRID: #{ssr.id},  Dest SSRID: #{dest_ssr.id} (#{dest_ssr_exists ? 'Existing' : 'New'}),  LIs Moved: #{line_items_moved.to_s}"
        end
      end
    end
    service.update!(organization_id: dest_org.id)
  end
  puts "\nDone!"
end

def ssr_contains_just_this_service?(ssr, service)
  ssr.line_items.pluck(:service_id).uniq == [service.id]
end
