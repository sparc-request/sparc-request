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

desc "Remove Duplicate Past Status"
task :remove_duplicate_past_status => :environment do
  # Replace null date value for past statuses with date field to the date of the status that the SSR got changed to
  grouped_past_status_with_nil_date = PastStatus.where(date: nil).group_by(&:sub_service_request_id)
  grouped_past_status_with_nil_date.each do |k,v|
    if SubServiceRequest.exists?(k)
      past_status_lookup = SubServiceRequest.find(k).past_status_lookup
      if past_status_lookup.count == 1
        nil_date_past_status = past_status_lookup.first
        new_date = nil_date_past_status.created_at
        nil_date_past_status.update_attribute(:date, new_date)
        puts "Updated PastStatus with a nil value for date, ID: #{nil_date_past_status.id} with date: #{new_date}"
      else
        nil_date_past_status = past_status_lookup.select{ |past_status| past_status.date == nil }
        filtered_statuses = past_status_lookup.reject { |past_status| past_status.date == nil }.sort_by(&:date)
        new_date = filtered_statuses.first.date
        nil_date_past_status.first.update_attribute(:date, new_date)
        puts "Replaced nil date value for PastStatus ID: #{nil_date_past_status.first.id} with date: #{new_date}"
      end
    end
  end

  # Find duplicate past status dates under an SSR, then check to see if status and changed_to(status) for a past_status is the same.  If both these conditions are met, we have found a duplicate past status which needs to be destroyed

  past_status_count = 0
  grouped_by_ssr = PastStatus.all.group_by(&:sub_service_request_id)
  grouped_by_ssr.each do |k,v|
    if SubServiceRequest.exists?(k)
      # calling the past_status_lookup method allows us to see "changed_to" (status)
      past_status_lookup = SubServiceRequest.find(k).past_status_lookup
      # find timestamps that are identical down to the minute
      timestamps_with_cleared_seconds = past_status_lookup.map { |ps| ps.date.change(:sec => 0) unless ps.date == nil } 
      duplicate = timestamps_with_cleared_seconds.select{ |e| timestamps_with_cleared_seconds.count(e) > 1 }
      if duplicate.present?
        status_changed_to = Hash[past_status_lookup.map{|f| [f.id, [f.status, f.changed_to]]}]
        status_changed_to.each do |status_array|
          if status_array[1].uniq.count == 1
            puts "Destroying past_status with an id of #{status_array[0]} with a date of #{PastStatus.find(status_array[0]).date}"
            PastStatus.find(status_array[0]).destroy
            past_status_count += 1
          end
        end
      end
    end
  end
  puts "Destroyed a total of #{past_status_count} duplicate past_statuses."
end

