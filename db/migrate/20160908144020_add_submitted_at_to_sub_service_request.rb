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

class AddSubmittedAtToSubServiceRequest < ActiveRecord::Migration[4.2]
  def change
    add_column :sub_service_requests, :submitted_at, :timestamp

    SubServiceRequest.where(status: 'submitted').each do |ssr|
      past_status = ssr.past_statuses.order('date').last

      ssr.update_attribute(:submitted_at, past_status.date) unless past_status.nil?
    end

    SubServiceRequest.where.not(status: 'submitted').joins(:past_statuses).where(past_statuses: { status: 'submitted' }).each do |ssr|
      statuses = ssr.past_statuses
      changed_from_submitted_index = statuses.rindex{|past_status| past_status.status == 'submitted'}
      changed_to_submitted = statuses[(changed_from_submitted_index - 1)]

      ssr.update_attribute(:submitted_at, changed_to_submitted.date)
    end
  end
end
