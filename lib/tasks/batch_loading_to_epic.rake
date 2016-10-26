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

namespace :epic do
  desc "Batch load from Epic Queue"
  task :batch_load, [:automate] => [:environment] do |t, args|
    args.with_defaults(:automate => false)

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def send_epic_queue_report protocol_ids
      CSV.open("tmp/epic_queue_report.csv", "wb") do |csv|
        csv << [Time.now.strftime('%m/%d/%Y')]
        protocol_ids.each do |pid|
          protocol = Protocol.find pid

          csv << [protocol.id, protocol.short_title, protocol.funding_source]
          csv << ["First Name", "Last Name", "Email Address", "LDAP UID", "Role"]
          protocol.project_roles.each do |pr|
            csv << [pr.identity.first_name, pr.identity.last_name, pr.identity.email, pr.identity.ldap_uid, pr.role]
          end
          csv << []
          csv << []
        end
      end
      Notifier.epic_queue_report.deliver
    end

    manual_protocol_ids = prompt("Enter a single or comma separated list of protocol ids (leave blank to use the EPIC queue): ") unless args.automate

    if EpicQueue.all.size > 0 or not manual_protocol_ids.blank?
      confirm = "No"
      protocol_ids = []

      if args.automate
        confirm = "Yes"
        protocol_ids = EpicQueue.all.map(&:protocol_id)
      else
        if manual_protocol_ids.blank?
          protocol_ids = EpicQueue.all.map(&:protocol_id)
        else
          protocol_ids = manual_protocol_ids.gsub(/\s+/, "").split(",").map(&:to_i)
        end

        confirm = prompt("Are you sure you want to batch load #{protocol_ids.inspect}? (Yes/No) ")
      end

      sent = []
      failed = []
      if confirm == "Yes"

        send_epic_queue_report(protocol_ids)

        puts "Queue => #{protocol_ids.inspect.to_s}"

        protocol_ids.each do |id|
          begin
            p = Protocol.find id

            p.push_to_epic(EPIC_INTERFACE)

            # loop until the push is either complete or fails
            while not ['complete', 'failed'].include? p.last_epic_push_status
              p.reload
              sleep 1
            end


            if p.last_epic_push_status == 'failed' # i'm 99% sure this will never happen as failures get caught in the rescue block
              puts "#{p.short_title} (#{p.id}) failed to send to Epic"
              failed << p.id
              Notifier.epic_queue_error(p).deliver
            else
              puts "#{p.short_title} (#{p.id}) sent to Epic"
              sent << p.id
              q = EpicQueue.find_by_protocol_id(p.id) rescue false
              q.destroy if q
            end
          rescue Exception => e
            failed << p.id
            puts "#{p.short_title} (#{p.id}) failed to send to Epic with an exception"
            puts "Sent => #{sent.inspect.to_s}"
            puts "Failed => #{failed.inspect.to_s}"
            Notifier.epic_queue_error(p, e).deliver
            puts e
          end
        end
        puts "Sent => #{sent.inspect.to_s}"
        puts "Failed => #{failed.inspect.to_s}"
        
        Notifier.epic_queue_complete(sent, failed).deliver
      else
        puts "Batch load aborted"
      end
    else
      sent = []
      failed = []
      puts "Epic Queue is empty"
      Notifier.epic_queue_complete(sent, failed).deliver
    end
  end
end
