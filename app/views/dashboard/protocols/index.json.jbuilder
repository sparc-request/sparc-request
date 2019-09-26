authorized_user_protocols = Protocol.joins(:project_roles).where(project_roles: { identity: current_user }).ids
admin_protocols           = Protocol.for_admin(current_user.id).ids

json.total @protocol_count
json.rows (@protocols) do |protocol|
  access = authorized_user_protocols.include?(protocol.id) || admin_protocols.include?(protocol.id)

  json.id           protocol_id_link(protocol)
  json.short_title  protocol_short_title_link(protocol)
  json.pis          pis_display(protocol)
  json.requests     display_requests_button(protocol, access)
end
