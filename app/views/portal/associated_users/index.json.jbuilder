json.(@protocol_roles) do |pr|
  json.identity_id       pr.identity.id
  json.name              pr.identity.full_name
  json.role              USER_ROLES.detect { |_, v| v == pr.role }.first
  json.proxy_rights      PROXY_RIGHTS.key(pr.project_rights)
  json.email             pr.identity.email
  json.phone             pr.identity.phone
  json.protocol_id       @protocol.id
  json.edit              associated_users_edit_button(protocol_id: @protocol.id, user_id: pr.identity.id, pr_id: pr.id, permission: 'true', sub_service_request_id: @sub_service_request.id, current_user_role: pr.role)
  json.delete            associated_users_delete_button(protocol_id: @protocol.id, user_id: pr.identity.id, pr_id: pr.id, permission: 'true', sub_service_request_id: @sub_service_request.id, current_user_role: pr.role)
end
