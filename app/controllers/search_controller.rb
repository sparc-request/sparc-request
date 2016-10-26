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

class SearchController < ApplicationController
  before_filter :initialize_service_request
  before_filter :authorize_identity
  def services
    term              = params[:term].strip
    service_request   = ServiceRequest.find(session[:service_request_id])
    locked_ssrs       = service_request.sub_service_requests.reject{ |ssr| ssr.can_be_edited? }
    locked_org_ids    = locked_ssrs.map(&:organization_id)
    locked_child_ids  = Organization.authorized_child_organizations(locked_org_ids).map(&:id)

    results = Service.
                where("(name LIKE ? OR abbreviation LIKE ? OR cpt_code LIKE ?) AND is_available = ?", "%#{term}%", "%#{term}%", "%#{term}%", "1").
                where(organization: (Organization.available_cores | Organization.available_programs)).
                where.not(organization_id: locked_org_ids + locked_child_ids).
                reject { |s| (s.current_pricing_map rescue false) == false } # Why is this here?

    unless @sub_service_request.nil?
      results = results.reject{|s| s.parents.exclude? @sub_service_request.organization}
    end

    first_service = service_request.line_items.count == 0

    results = results.map { |s|
      {
        :parents      => s.parents.map(&:abbreviation).join(' | '),
        :label        => s.name,
        :value        => s.id,
        :description  => s.description,
        :sr_id        => session[:service_request_id],
        :from_portal  => session[:from_portal],
        :first_service => first_service,
        :abbreviation => s.abbreviation,
        :cpt_code     => s.cpt_code
      }
    }

    results = [{:label => 'No Results'}] if results.empty?

    render :json => results.to_json
  end

  def identities
    term = params[:term].strip
    results = Identity.search(term).map do |i|
      {
       :label              => i.display_name,
       :value              => i.id,
       :email              => i.email,
       :institution        => i.institution,
       :phone              => i.phone,
       :era_commons_name   => i.era_commons_name,
       :college            => i.college,
       :department         => i.department,
       :credentials        => i.credentials,
       :credentials_other  => i.credentials_other
      }
    end
    results = [{:label => 'No Results'}] if results.empty?
    render :json => results.to_json
  end
end
