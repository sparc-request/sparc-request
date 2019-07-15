json.(@protocol_roles) do |pr|
  json.name              "#{pr.identity.full_name} #{(pr.identity_id == @protocol.requester_id) ? '(Requester)' : ''}"
  json.role              PermissibleValue.get_value('user_role', pr.role)
  json.email             pr.identity.email
  json.phone             format_phone(pr.identity.phone)
  json.project_rights    PermissibleValue.get_value('proxy_right', pr.project_rights)
  json.epic_emr_access   pr.epic_access? ? 'Yes' : 'No'
  json.actions           authorized_user_actions(pr, @service_request)
end
