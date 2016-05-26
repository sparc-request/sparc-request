json.(@sub_service_requests) do |ssr|
  json.srid           ssr.display_id
  json.organization   ssr.org_tree_display
  json.status         AVAILABLE_STATUSES[ssr.status]
  json.notifications  ssr_notifications_display(ssr, @user)
  json.actions        ssr_actions_display(ssr, @user, @permission_to_edit, @admin_orgs)
end
