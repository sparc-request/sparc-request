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
  task fix_missing_ssr_ids: :environment do
    ssrs_with_missing_ssr_ids = SubServiceRequest.where(ssr_id: nil)

    puts "SSRs with missing ssr_ids - #{ssrs_with_missing_ssr_ids.count}"

    ssrs_with_missing_ssr_ids.each do |ssr|
      if ssr.protocol.next_ssr_id.nil?
        ssr.protocol.update_attribute(:next_ssr_id, 1)
        protocol_next_ssr_id = ssr.protocol.next_ssr_id
      else
        protocol_next_ssr_id = ssr.protocol.next_ssr_id
      end
      ssr.update_attribute(:ssr_id, "%04d" % protocol_next_ssr_id)
      puts "SSR updated with ssr_id of #{protocol_next_ssr_id}"
      ssr.protocol.update_attribute(:next_ssr_id, protocol_next_ssr_id + 1)
    end
  end
end
