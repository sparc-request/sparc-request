# Copyright © 2011 MUSC Foundation for Research Development
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

module Dashboard::SubServiceRequestsHelper

#********************Admin Index Begin**********************************


  def ssr_services_display ssr
    # %td{:style => "max-width: 135px; word-wrap: break-word;"}
    #   %ul.services_first
    #     %li
    #       - services = ssr.line_items.map(&:service).sort_by{|srv| srv.name}.map(&:name)

    #     - if services.size > 1
    #       %span.open_close_services{:style => 'display:inline-block'}
    #       %span.open_close_services{:style => 'display:none'}

    #     %span= services.shift
    #   %ul.services_rest{:style => 'display:none'}
    #     - services.each do |service|
    #       %li= service
  end

  def ssr_pis_display(ssr)
    # - pis = ssr.service_request.protocol.try(:principal_investigators).try(:map, &:full_name) || []
    # - if pis.size > 1
    #   - pis.each do |pi|
    #     = pi
    # - else
    #   = pis[0]
  end

#********************Admin Index End**********************************


  def candidate_service_options(services, include_cpt=false)
    services.map do |service|
      n = include_cpt ? service.display_service_name : service.name
      [n, service.id]
    end
  end

  def per_patient_line_items(line_items)
    line_items.map { |line_item| [line_item.service.name, line_item.id]}
  end

  def calculate_total
    if @sub_service_request
      total = @sub_service_request.direct_cost_total / 100.0
    end

    total
  end

  def user_display_total sub_service_request
    return (sub_service_request.direct_cost_total / 100.0)
  end

  def effective_current_total sub_service_request
    sub_service_request.set_effective_date_for_cost_calculations
    total = (sub_service_request.direct_cost_total / 100.0)
    sub_service_request.unset_effective_date_for_cost_calculations

    return total
  end

  def subsidy_user_display_total sub_service_request, subsidy
    pi_contribution = (subsidy.pi_contribution / 100.0)

    return user_display_total(sub_service_request) - pi_contribution
  end

  def subsidy_effective_current_total sub_service_request, subsidy
    pi_contribution = (subsidy.pi_contribution / 100.0)

    return effective_current_total(sub_service_request) - pi_contribution
  end

  #This is used to filter out ssr's on the cfw home page
  #so that clinical providers can only see ones that are
  #under their core.  Super users and clinical providers on the
  #ctrc can see all ssr's.
  def user_can_view_ssr?(study_tracker, ssr, user)
    can_view = false
    if user.is_super_user? || user.clinical_provider_for_ctrc? || (user.is_service_provider?(ssr) && (study_tracker == false)) 
      can_view = true
    else
      ssr.line_items.each do |line_item|
        clinical_provider_cores(user).each do |core|
          if line_item.core == core 
            can_view = true
          end
        end
      end
    end
    can_view
  end

  def clinical_provider_cores(user)
    cores = []
    user.clinical_providers.each do |provider|
      cores << provider.core
    end

    cores
  end

  def full_user_name_from_id id
    user = Identity.find(id)

    user.display_name
  end

  def extract_subsidy_audit_data object, convert_to_dollars=false
    if object
      display = []
      if object.kind_of?(Array) && !object.empty?
        object.each do |element|
          if convert_to_dollars
            display << (element.to_f / 100)
          else
            display << element
          end
        end
        return (display[0] ? display[0].to_s : "0") + " => " + (display[1] ? display[1].to_s : "0")
      else
        return convert_to_dollars ? (object.to_f / 100) : object
      end
    end
  end
end
