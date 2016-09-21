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

class FixEmptyArmsAgain < ActiveRecord::Migration
  def up
    service_requests = ServiceRequest.all

    ActiveRecord::Base.transaction do
      service_requests.each do |service_request|
        service_request.arms.each do |arm|
          # Remove visit groupings that are for one time fee line items
          one_time_fee_visit_groupings = arm.visit_groupings.select do |vg|
            vg.line_item.service.is_one_time_fee?
          end

          if one_time_fee_visit_groupings.count > 0 then
            say "Destroying #{one_time_fee_visit_groupings.count} visit groupings because they are for one time fee line items"
            one_time_fee_visit_groupings.each do |vg|
              vg.destroy
            end
          end

          # Remove the arm if it no longer has any visit groupings (i.e.
          # the service request only has one time fee line items)
          if arm.visit_groupings.empty? then
            say "Destroying arm #{arm.id} because it has has no visit groupings"
            arm.destroy
          end
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end