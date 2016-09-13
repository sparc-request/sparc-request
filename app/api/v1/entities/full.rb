# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

#Copyright © 2011-2016 MUSC Foundation for Research Development.
#All rights reserved.

module V1

  class ArmFull < ArmShallow
    root 'arms', 'arm'

    expose  :name,
            :visit_count,
            :subject_count,
            :protocol_id,
            :new_with_draft,
            :minimum_visit_count,
            :minimum_subject_count
  end

  class ClinicalProviderFull < ClinicalProviderShallow
    root 'clinical_providers', 'clinical_provider'

    expose  :identity_id,
            :organization_id
  end

  class IdentityFull < IdentityShallow
    root 'identities', 'identity'

    expose  :email,
            :first_name,
            :last_name,
            :ldap_uid
  end

  class HumanSubjectsInfoFull < HumanSubjectsInfoShallow
    root 'human_subjects_infos', 'human_subjects_info'

    expose  :protocol_id,
            :nct_number,
            :hr_number,
            :pro_number,
            :irb_of_record,
            :submission_type,
            :approval_pending

    with_options(format_with: :iso_timestamp) do
      expose :irb_approval_date
      expose :irb_expiration_date
    end
  end

  class LineItemFull < LineItemShallow
    root 'line_items', 'line_item'

    expose  :service_request_id,
            :sub_service_request_id,
            :service_id,
            :ssr_id,
            :optional,
            :quantity,
            :units_per_quantity,
            :per_unit_cost,
            :one_time_fee

    with_options(format_with: :iso_timestamp) do
      expose :complete_date
      expose :in_process_date
    end
  end

  class LineItemsVisitFull < LineItemsVisitShallow
    root 'line_items_visits', 'line_items_visit'

    expose  :arm_id,
            :line_item_id,
            :subject_count
  end

  class ProcessSsrsOrganizationFull < ProcessSsrsOrganizationShallow
    root 'process_ssrs_organizations', 'process_ssrs_organization'

    expose :name
  end

  class ProjectRoleFull < ProjectRoleShallow
    root 'project_roles', 'project_role'

    expose  :identity_id,
            :protocol_id,
            :project_rights,
            :role,
            :role_other
  end

  class ProtocolFull < ProtocolShallow
    root 'protocols', 'protocol'

    expose  :type,
            :next_ssr_id,
            :short_title,
            :title,
            :sponsor_name,
            :brief_description,
            :indirect_cost_rate,
            :study_phase,
            :udak_project_number,
            :funding_rfa,
            :funding_status,
            :potential_funding_source,
            :funding_source,
            :federal_grant_serial_number,
            :federal_grant_title,
            :federal_grant_code_id,
            :federal_non_phs_sponsor,
            :federal_phs_sponsor,
            :potential_funding_source_other,
            :funding_source_other,
            :last_epic_push_time,
            :last_epic_push_status,
            :billing_business_manager_static_email,
            :selected_for_epic,
            :study_type_question_group_id,
            :archived

    with_options(format_with: :iso_timestamp) do
      expose :start_date
      expose :end_date
      expose :potential_funding_start_date
      expose :funding_start_date
      expose :recruitment_start_date
      expose :recruitment_end_date
    end
  end

  class ProjectFull < ProtocolFull
    root 'protocols', 'protocol'
  end

  class StudyFull < ProtocolFull
    root 'protocols', 'protocol'
  end

  class ServiceFull < ServiceShallow
    root 'services', 'service'

    expose  :name,
            :abbreviation,
            :order,
            :description,
            :eap_id,
            :is_available,
            :service_center_cost,
            :cpt_code,
            :charge_code,
            :revenue_code,
            :organization_id,
            :send_to_epic,
            :revenue_code_range_id,
            :one_time_fee,
            :line_items_count,
            :components

    expose  :process_ssrs_organization, using: V1::ProcessSsrsOrganizationFull
  end

  class ServiceRequestFull < ServiceRequestShallow
    root 'service_requests', 'service_request'

    expose  :protocol_id,
            :status,
            :approved,
            :subject_count

    with_options(format_with: :iso_timestamp) do
      expose :consult_arranged_date
      expose :pppv_complete_date
      expose :pppv_in_process_date
      expose :submitted_at
    end
  end

  class SubServiceRequestFull < SubServiceRequestShallow
    root 'sub_service_requests', 'sub_service_request'

    expose  :id, as: :sparc_id
    expose  :service_request_id,
            :organization_id,
            :owner_id,
            :ssr_id,
            :nursing_nutrition_approved,
            :lab_approved,
            :imaging_approved,
            :committee_approved,
            :in_work_fulfillment,
            :routing,
            :org_tree_display,
            :grand_total,
            :service_requester_id

    expose  :formatted_status, as: :status

    with_options(format_with: :iso_timestamp) do
      expose :status_date
      expose :consult_arranged_date
      expose :requester_contacted_date
    end
  end

  class VisitFull < VisitShallow
    root 'visits', 'visit'

    expose  :quantity,
            :billing,
            :research_billing_qty,
            :insurance_billing_qty,
            :effort_billing_qty,
            :line_items_visit_id,
            :visit_group_id
  end

  class VisitGroupFull < VisitGroupShallow
    root 'visit_groups', 'visit_group'

    expose  :name,
            :arm_id,
            :position,
            :day,
            :window_before,
            :window_after
  end
end
