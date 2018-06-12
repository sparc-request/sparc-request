json.(@sub_service_requests) do |ssr|
  json.srid           ssr.display_id
  json.organization   ssr.org_tree_display
  json.owner          display_owner(ssr)
  json.status         PermissibleValue.get_value('status', ssr.status)
  json.notifications  ssr_notifications_display(ssr, @user, @sr_table)
  json.actions        ssr_actions_display(ssr, @user, @permission_to_edit, @admin_orgs, @show_view_ssr_back)
  json.surveys        display_ssr_submissions(ssr)
end
