# Copyright © 2011-2019 MUSC Foundation for Research Development
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
  include ServicesHelper

  before_action :initialize_service_request, only: [:services]
  before_action :authorize_identity, only: [:services]

  def services_search
    term = params[:term].strip
    results = Service.
                eager_load(:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, :parent]]]).
                where("(services.name LIKE ? OR services.abbreviation LIKE ? OR services.cpt_code LIKE ? OR services.eap_id LIKE ?) AND services.is_available = 1", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%").
                sort_by{ |s| s.organization_hierarchy(true, false, false, true).map{ |o| [o.order, o.abbreviation] }.flatten }

    results.map!{ |service|
      {
        breadcrumb:     breadcrumb_text(service),
        label:          service.name,
        value:          service.id,
        description:    raw(service.description),
        abbreviation:   service.abbreviation,
        cpt_code_text:  cpt_code_text(service),
        eap_id_text:    eap_id_text(service),
        pricing_text:   service_pricing_text(service),
        term:           term
      }
    }

    render json: results.to_json
  end

  def services
    term              = params[:term].strip
    locked_org_ids    = @service_request.
                          sub_service_requests.
                          reject{ |ssr| !ssr.is_locked? }.
                          map(&:organization_id)
    locked_child_ids  = Organization.authorized_child_organization_ids(locked_org_ids)

    results = Service.
                eager_load(:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, :parent]]]).
                where("(services.name LIKE ? OR services.abbreviation LIKE ? OR services.cpt_code LIKE ? OR services.eap_id LIKE ?) AND services.is_available = 1", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%").
                where.not(organization_id: locked_org_ids + locked_child_ids).
                reject { |s| (s.current_pricing_map rescue false) == false }. # Why is this here? ##Agreed, why????
                sort_by{ |s| s.organization_hierarchy(true, false, false, true).map{ |o| [o.order, o.abbreviation] }.flatten }

    unless @sub_service_request.nil?
      results.reject!{ |s| s.parents.exclude?(@sub_service_request.organization) }
    end

    results.map! { |s|
      {
        breadcrumb:     breadcrumb_text(s),
        label:          s.name,
        value:          s.id,
        description:    raw(s.description),
        abbreviation:   s.abbreviation,
        cpt_code_text:  cpt_code_text(s),
        eap_id_text:    eap_id_text(s),
        pricing_text:   service_pricing_text(s),
        term:           term
      }
    }

    render json: results.to_json
  end

  def organizations
    term                  = params[:term].strip
    org_available_query   = params[:show_available_only] == 'true' ? " AND is_available = 1" : ""
    serv_available_query  = params[:show_available_only] == 'true' ? " AND services.is_available = 1" : ""

    results = (Organization.
                includes(parent: { parent: :parent }).
                where("(name LIKE ? OR abbreviation LIKE ?)#{org_available_query}", "%#{term}%", "%#{term}%") +
              Service.
                eager_load(:pricing_maps, organization: [:pricing_setups, parent: [:pricing_setups, parent: [:pricing_setups, :parent]]]).
                where("(services.name LIKE ? OR services.abbreviation LIKE ? OR services.cpt_code LIKE ? OR services.eap_id LIKE ?)#{serv_available_query}", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%")).
              sort_by{ |item| item.organization_hierarchy(true, false, false, true).map{ |o| [o.order, o.abbreviation] }.flatten }

    results.map! { |item|
      {
        id:             item.id,
        name:           item.name,
        abbreviation:   item.abbreviation,
        type:           item.class.base_class.name.downcase,
        text_color:     "text-#{item.class.name.downcase}",
        cpt_code_text:  item.is_a?(Service) ? cpt_code_text(item) : "",
        eap_id_text:    item.is_a?(Service) ? eap_id_text(item) : "",
        inactive_tag:   inactive_text(item),
        breadcrumb:     breadcrumb_text(item),
        pricing_text:   item.is_a?(Service) ? service_pricing_text(item) : "",
        description:    raw(item.description)
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

  def inactive_text(item)
    text = item.is_available ? "" : "(Inactive)"
  end

  def breadcrumb_text(item)
    if item.parents.any?
      breadcrumb = []
      item.parents.reverse.each do |parent|
        breadcrumb << "<span class='text-#{parent.type.downcase}'>#{parent.abbreviation} </span>"
        breadcrumb << "<span class='inline-glyphicon glyphicon glyphicon-triangle-right'> </span>"
      end
      breadcrumb.pop
      breadcrumb.join.html_safe
    end
  end
end
