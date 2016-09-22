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

desc 'Remove first_draft requests that are over 30 days old'
task :remove_historical_first_draft => :environment do
  Rails.application.eager_load!

  ActiveRecord::Base.descendants.each do |model|
    if model.respond_to? 'auditing_enabled'
      model.auditing_enabled = false
    end
  end

  end_date = 30.days.ago

  CSV.open("tmp/removed_historical_first_draft_#{end_date.strftime('%m%d%Y')}.csv", "wb") do |csv|

    SubServiceRequest.where("status = ? and updated_at < ?", 'first_draft', end_date).find_each do |ssr|
      service_request = ssr.service_request
      puts "Removing SubServiceRequest ##{ssr.id}"
      csv << [ssr.service_request.protocol_id, ssr.id, ssr.updated_at]
      ssr.destroy!

      service_request.reload

      if service_request.sub_service_requests.empty?
        puts "Removing ServiceRequest ##{service_request.id}"
        csv << [ssr.service_request.protocol_id, ssr.id, ssr.updated_at, service_request.id]
        service_request.destroy!
      end
    end
  end

  ActiveRecord::Base.descendants.each do |model|
    if model.respond_to? 'auditing_enabled'
      model.auditing_enabled = true
    end
  end

end
