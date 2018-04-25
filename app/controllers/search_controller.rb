# Copyright © 2011-2018 MUSC Foundation for Research Development
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
  before_action :initialize_service_request, only: [:services]
  before_action :authorize_identity, only: [:services]

  def services
    term              = params[:term].strip
    locked_org_ids    = @service_request.
                          sub_service_requests.
                          reject{ |ssr| !ssr.is_locked? }.
                          map(&:organization_id)
    locked_child_ids  = Organization.authorized_child_organization_ids(locked_org_ids)

    results = Service.
                where("(name LIKE ? OR abbreviation LIKE ? OR cpt_code LIKE ?) AND is_available = 1", "%#{term}%", "%#{term}%", "%#{term}%").
                where.not(organization_id: locked_org_ids + locked_child_ids).
                reject { |s| (s.current_pricing_map rescue false) == false } # Why is this here?

    unless @sub_service_request.nil?
      results.reject!{ |s| s.parents.exclude?(@sub_service_request.organization) }
    end

    results.map! { |s|
      {
        parents:        s.organization_hierarchy(false, false, true),
        label:          s.name,
        value:          s.id,
        description:    (s.description.nil? || s.description.blank?) ? t(:proper)[:catalog][:no_description] : s.description,
        abbreviation:   s.abbreviation,
        cpt_code:       s.cpt_code,
        term:           term
      }
    }

    render json: results.to_json
  end

  def organizations
    term = params[:term].strip
    if params[:show_available_only] == 'false' #the param name is the opposite of what is currently displayed
      query_available = " AND is_available = 1"
    end

    results = Organization.where("(name LIKE ? OR abbreviation LIKE ?)#{query_available}", "%#{term}%", "%#{term}%") +
              Service.where("(name LIKE ? OR abbreviation LIKE ? OR cpt_code LIKE ?)#{query_available}", "%#{term}%", "%#{term}%", "%#{term}%")

    results.map! { |org|
      {
        name: org.name,
        abbreviation: org.abbreviation,
        type: org.class.to_s,
        text_color: "text-#{org.class.to_s.downcase}",
        cpt_code: cpt_code_text(org),
        inactive_tag: inactive_text(org),
        parents: org.parents.reverse.map{ |p| "##{p.class.to_s.downcase}-#{p.id}" },
        value_selector: "##{org.class.to_s.downcase}-#{org.id}"
      }
    }

    render json: results.to_json
  end

  def identities
    term = params[:term].strip
    results = Identity.search(term).map { |i|
      {
        identity_id: i.id,
        name: i.full_name,
        email: i.email
      }
    }
    render json: results.to_json
  end

  private

  def cpt_code_text(org)
    text = org.class == Service ? "CPT code: #{org.cpt_code}" : ""
  end

  def inactive_text(org)
    text = org.is_available ? "" : "(Inactive)"
  end
end
