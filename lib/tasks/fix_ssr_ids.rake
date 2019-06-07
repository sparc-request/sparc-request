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

desc 'Fix ssr_ids'
task fix_ssr_ids: :environment do

  Protocol.find_each do |protocol|
    requests = protocol.sub_service_requests.group_by(&:ssr_id)
    if protocol.sub_service_requests.present?
      last_ssr_id = protocol.sub_service_requests.sort_by(&:ssr_id).last.ssr_id.to_i
      dup_requests_to_be_incremented = []

      requests.each do |ssr_id, ssr_array|
        if ssr_array.size > 1 # we have duplicate ssr_ids
          ssr_array.each_with_index do |ssr, index|
            if index > 0
              dup_requests_to_be_incremented << ssr # place all requests with dup ids in an array to deal with later
            end
          end
        end
      end

      if dup_requests_to_be_incremented.size > 0
        dup_requests_to_be_incremented.each do |ssr|
          ssr.ssr_id = "%04d" % (last_ssr_id + 1)
          ssr.save(validate: false) 
          last_ssr_id += 1
        end
      end

      # we need to increment the protocol's next_ssr_id if we had some duplicates
      new_last_ssr_id = protocol.sub_service_requests.sort_by(&:ssr_id).last.ssr_id.to_i
      if protocol.next_ssr_id? && (protocol.next_ssr_id <= new_last_ssr_id)
        protocol.next_ssr_id = new_last_ssr_id + 1
        protocol.save(validate: false)
      end
    end
  end

  # double check that we caught all the duplicates
  Protocol.find_each do |protocol|
    requests = protocol.sub_service_requests
    ssr_ids = requests.map(&:ssr_id)
    dups = ssr_ids.uniq
    if ssr_ids.length != dups.length
      puts "Found dups"
      puts protocol.id
    end
  end
end