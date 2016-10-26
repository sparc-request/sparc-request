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

class CatalogsController < ApplicationController
  before_filter :initialize_service_request
  before_filter :authorize_identity

  def update_description
    @organization 		= Organization.find params[:id]
    @service_request 	= ServiceRequest.find session[:service_request_id]
    @from_portal      = session[:from_portal]
    @program_is_process_ssr = params[:program_is_process_ssr] == 'true'

    @locked_org_ids = []
    if @service_request.protocol.present?
      @service_request.sub_service_requests.each do |ssr|
        organization = ssr.organization
        if organization.has_editable_statuses?
          self_or_parent_id = ssr.find_editable_id(organization.id)
          if !EDITABLE_STATUSES[self_or_parent_id].include?(ssr.status)
            @locked_org_ids << self_or_parent_id
            @locked_org_ids << organization.all_children(Organization.all).map(&:id)
          end
        end
      end

      unless @locked_org_ids.empty?
        @locked_org_ids = @locked_org_ids.flatten.uniq
      end
    end
  end
end
