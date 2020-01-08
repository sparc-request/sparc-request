json.(@protocol_roles) do |pr|
  json.name           "#{pr.identity.full_name} #{(pr.identity_id == @protocol.requester_id) ? '(Requester)' : ''}"
  json.role           PermissibleValue.get_value('user_role', pr.role)
  json.email          pr.identity.email
  json.phone          format_phone(pr.identity.phone)
  json.project_rights PermissibleValue.get_value('proxy_right', pr.project_rights)
  json.epic_access    pr.epic_access? ? t('constants.yes_select') : t('constants.no_select')
  json.actions        authorized_user_actions(pr, permission: @permission_to_edit || @admin, admin: @admin)
end
