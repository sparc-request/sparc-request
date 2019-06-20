authorized_user_protocols = Protocol.joins(:project_roles).where(project_roles: { identity: current_user }).ids
admin_protocols           = Protocol.for_admin(current_user.id).ids

json.total @filterrific.find.length
json.rows (@filterrific.find.includes(:principal_investigators, :sub_service_requests).sorted(params[:sort], params[:order]).limit(params[:limit]).offset(params[:offset])) do |protocol|
  access = authorized_user_protocols.include?(protocol.id) || admin_protocols.include?(protocol.id)

  json.id           protocol_id_button(protocol)
  json.short_title  protocol.short_title
  json.pis          pis_display(protocol)
  json.requests     display_requests_button(protocol, access)
end
