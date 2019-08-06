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

module NotifierHelper
  def intro_determination(status)
    case status
    when 'ssr_destroyed'
      render "notifier/deleted_all_services_from_cart"
    when 'get_a_cost_estimate'
      render "notifier/welcome"
    when 'submitted'
      render "notifier/welcome_for_submitted_status"
    when 'request_amendment'
      render "notifier/request_amendment"
    end
  end

  def display_arm_table(service_request)
    if service_request.has_per_patient_per_visit_services? and service_request.arms.count > 0
      render "notifier/arm_information"
    end
  end

  def display_srid_table(ssrs_to_be_displayed, status)
    if ssrs_to_be_displayed
      if status == 'ssr_destroyed'
        render "notifier/deleted_srid_information"
      else
        render "notifier/srid_information"
      end
    end
  end

  def display_audit_table(status, audit_report)
    if status == 'request_amendment' && audit_report.present? && audit_report[:line_items].present?
      render "audit_action"
    end   
  end

  def determine_ssr(last_change, action_name, deleted_ssrs)
    ssr_id = last_change.audited_changes['sub_service_request_id']
    if last_change.action == 'destroy'
      # This condition signifies a deleted SSR
      if SubServiceRequest.where(id: ssr_id).empty? && action_name == 'notify_user'
        ssr = deleted_ssrs.select{ |ssr| ssr.auditable_id == ssr_id }.first
      else
        ssr = SubServiceRequest.find(ssr_id)
      end
    else
      ssr = LineItem.exists?(last_change.auditable_id) ? LineItem.find(last_change.auditable_id).sub_service_request : nil
    end
    ssr
  end
end