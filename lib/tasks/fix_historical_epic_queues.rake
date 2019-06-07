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
  task fix_historical_epic_queues: :environment do

    puts "Fetching Epic Queue Records with an origin of pi_email_approval since May 2017"

    epic_queue_records = EpicQueueRecord.where(
      origin: 'pi_email_approval',
      created_at: Date.parse('01-05-2017')..Date.today
    )

    puts "#{epic_queue_records.count} Epic Queue Records with an origin of pi_email_approval since May 2017"

    eqr_updated = []

    epic_queue_records.each do |eqr|
      updated_record = eqr.update_attribute(:origin, 'overlord_push')
      eqr_updated << updated_record
    end

    puts "#{eqr_updated.count} Epic Queue Records updated"

    puts "Finding duplicated Epic Queues for deletion..."

    duplicated_eqs = []

    EpicQueueRecord.all.each do |eqr|
      eq = EpicQueue.find_by(protocol_id: eqr.protocol_id, identity_id: eqr.identity_id)
      if !eq.nil?
        deleted_eq = eq.destroy
        duplicated_eqs << deleted_eq
      end
    end

    puts "#{duplicated_eqs.count} duplicated Epic Queues deleted"

    puts "Done"
  end
end
