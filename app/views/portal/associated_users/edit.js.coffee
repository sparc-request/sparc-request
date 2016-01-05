$("#modal_place").html("<%= escape_javascript(render(partial: 'portal/associated_users/edit', locals: { protocol: @protocol, protocol_role: @protocol_role, identity: @identity, type: 'edit' })) %>")
$("#modal_place").modal 'show'
