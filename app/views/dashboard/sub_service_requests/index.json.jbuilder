json.(@sub_service_requests) do |ssr|
  json.srid           ssr_name_display(ssr, context: false)
  json.owner          ssr.owner.try(&:full_name)
  json.status         PermissibleValue.get_value('status', ssr.status)
  json.surveys        render 'dashboard/sub_service_requests/forms_dropdown.html', sub_service_request: ssr
  json.actions        ssr_actions(ssr, @admin_orgs)
  json.data           row_style: 'bg-warning'
end
