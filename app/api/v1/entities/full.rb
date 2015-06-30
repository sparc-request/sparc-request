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

  class LineItemFull < LineItemShallow
    root 'line_items', 'line_item'

    format_with(:iso_timestamp) { |dt| dt ? dt.iso8601 : nil }

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
            :potential_funding_start_date,
            :funding_source,
            :funding_start_date,
            :federal_grant_serial_number,
            :federal_grant_title,
            :federal_grant_code_id,
            :federal_non_phs_sponsor,
            :federal_phs_sponsor,
            :potential_funding_source_other,
            :funding_source_other,
            :last_epic_push_time,
            :last_epic_push_status,
            :start_date,
            :end_date,
            :billing_business_manager_static_email,
            :recruitment_start_date,
            :recruitment_end_date,
            :selected_for_epic
  end

  class ProjectFull < ProtocolFull
    root 'protocols', 'protocol'
  end

  class StudyFull < ProtocolFull
    root 'protocols', 'protocol'
  end

  class ServiceLevelComponentFull < ServiceLevelComponentShallow
    root 'service_level_components', 'service_level_component'

    expose  :component,
            :position
  end

  class ServiceFull < ServiceShallow
    root 'services', 'service'

    expose  :name,
            :abbreviation,
            :order,
            :description,
            :is_available,
            :service_center_cost,
            :cpt_code,
            :charge_code,
            :revenue_code,
            :organization_id,
            :send_to_epic,
            :revenue_code_range_id,
            :service_level_components_count,
            :one_time_fee,
            :line_items_count

    expose  :process_ssrs_organization, using: V1::ProcessSsrsOrganizationFull
  end

  class ServiceRequestFull < ServiceRequestShallow
    root 'service_requests', 'service_request'

    format_with(:iso_timestamp) { |dt| dt ? dt.iso8601 : nil }

    expose  :protocol_id,
            :status,
            :service_requester_id,
            :notes,
            :approved,
            :subject_count

    with_options(format_with: :iso_timestamp) do
      expose :consult_arranged_date
      expose :pppv_complete_date
      expose :pppv_in_process_date
      expose :requester_contacted_date
      expose :submitted_at
    end
  end

  class SubServiceRequestFull < SubServiceRequestShallow
    root 'sub_service_requests', 'sub_service_request'

    format_with(:iso_timestamp) { |dt| dt ? dt.iso8601 : nil }

    expose  :id, as: :sparc_id
    expose  :service_request_id,
            :organization_id,
            :owner_id,
            :ssr_id,
            :nursing_nutrition_approved,
            :lab_approved,
            :imaging_approved,
            :src_approved,
            :in_work_fulfillment,
            :routing,
            :org_tree_display,
            :grand_total,
            :stored_percent_subsidy

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
