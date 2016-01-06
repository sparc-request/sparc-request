json.(sub_service_request)

json.id sub_service_request.id
json.srid full_ssr_id(sub_service_request)
json.status AVAILABLE_STATUSES[sub_service_request.status]
json.short_title sub_service_request.service_request.protocol.try(:short_title)
json.submitted format_date(sub_service_request.service_request.submitted_at)
json.service ssr_services_display(sub_service_request)
json.requester sub_service_request.service_request.service_requester.try(:full_name)
json.pi ssr_pis_display(sub_service_request)
json.assigned sub_service_request.owner.try(:full_name)
json.org_list sub_service_request.org_tree_display
