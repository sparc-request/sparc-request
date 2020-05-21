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

class RemoveGetACostEstimateDefault < ActiveRecord::Migration[5.2]
  def up
    ServiceRequest.reset_column_information
    SubServiceRequest.reset_column_information

    if pv = PermissibleValue.find_by_key('get_a_cost_estimate')
      pv.update_attribute(:default, false)
    end

    if s = Setting.find_by_key('updatable_statuses')
      # This should be an array but for some reason on Travis
      # it's being treated as the raw string value
      if s.value.is_a?(String)
        statuses = s.value.gsub("\"get_a_cost_estimate\",", "")
      else
        statuses = s.value.reject{ |status| status == 'get_a_cost_estimate' }
      end
      s.update_attribute(:value, statuses)
    end

    AvailableStatus.joins(:organization).where(status: 'get_a_cost_estimate', organizations: { use_default_statuses: true }).update_all(selected: false)
    EditableStatus.joins(:organization).where(status: 'get_a_cost_estimate', organizations: { use_default_statuses: true }).update_all(selected: false)

    ServiceRequest.eager_load(:sub_service_requests).where(status: 'get_a_cost_estimate').each do |sr|
      if sr.previously_submitted?
        sr.update_attribute(:status, 'submitted')
        sr.update_attribute(:submitted_at, Time.now)

        sr.sub_service_requests.select{ |ssr| ssr.status == 'get_a_cost_estimate' }.each do |ssr|
          ssr.update_attribute(:status, 'submitted')
          ssr.update_attribute(:submitted_at, Time.now)
        end
      else
        sr.update_attribute(:status, 'draft')
        sr.sub_service_requests.select{ |ssr| ssr.status == 'get_a_cost_estimate' }.each do |ssr|
          ssr.update_attribute(:status, 'draft')
        end
      end
    end

    SubServiceRequest.eager_load(:service_request).where(status: 'get_a_cost_estimate').each do |ssr|
      if ssr.service_request.previously_submitted?
        ssr.update_attribute(:status, 'submitted')
        ssr.update_attribute(:submitted_at, Time.now)
      else
        ssr.update_attribute(:status, 'draft')
      end
    end
  end

  def down
    if pv = PermissibleValue.find_by_key('get_a_cost_estimate')
      pv.update_attribute(:default, true)
    end

    if s = Setting.find_by_key('updatable_statuses')
      statuses = s.value.append('get_a_cost_estimate')
      s.update_attribute(:value, statuses)
    end
  end
end
