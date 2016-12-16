json.(@protocol_roles) do |pr|
  json.identity_id       pr.identity_id
  json.name              "#{pr.identity.full_name} #{(pr.identity_id == @protocol.requester_id) ? '(Requester)' : ''}"
  json.role              USER_ROLES.detect { |_, v| v == pr.role }.first
  json.proxy_rights      PROXY_RIGHTS.key(pr.project_rights)
  json.epic_emr_access   pr.epic_access? ? 'Yes' : 'No'
  json.email             pr.identity.email
  json.phone             pr.identity.phone
  json.protocol_id       pr.protocol_id
  json.edit              associated_users_edit_button(pr, @permission_to_edit || @admin)
  json.delete            associated_users_delete_button(pr, @permission_to_edit || @admin)
end
