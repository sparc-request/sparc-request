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

class AddNewStatusToPastStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :past_statuses, :new_status, :string

    progress_bar = ProgressBar.new(PastStatus.count)
    PastStatus.find_each(batch_size: 500) do |past_status|
      #Clean up past statuses that reference a missing sub_service_request
      if past_status.sub_service_request.nil?
        past_status.destroy
        progress_bar.increment!
        next
      end

      PastStatus.where(sub_service_request_id: past_status.sub_service_request_id).reorder(date: :desc, id: :desc).each_with_index do |sibling_past_status, index|
        if index == 0
          #Use current ssr status to fill in the most recent past_status's "new status"
          sibling_past_status.update_attribute(:new_status, sibling_past_status.sub_service_request.status)
        else
          #Otherwise use variable that will have been created on the previous loop
          sibling_past_status.update_attribute(:new_status, @new_status)
        end
        #Set variable for next descending past_status to use
        @new_status = sibling_past_status.status
      end
      progress_bar.increment!
    end
  end
end
