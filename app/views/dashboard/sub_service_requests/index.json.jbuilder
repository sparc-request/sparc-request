json.(@sub_service_requests) do |ssr|
  json.srid           ssr.display_id
  json.organization   ssr.org_tree_display
  json.owner          ssr.owner.try(&:full_name)
  json.status         display_status(ssr)
  json.submitted_on   format_datetime(ssr.submitted_at)
  json.surveys        render 'dashboard/sub_service_requests/forms_dropdown.html', sub_service_request: ssr
  json.actions        ssr_actions(ssr, @admin_orgs)
end
