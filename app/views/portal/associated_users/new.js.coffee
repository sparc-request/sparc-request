$("#modal_place").html("<%= escape_javascript(render(partial: 'portal/associated_users/new', locals: { protocol: @protocol, protocol_role: @protocol_role, identity: @identity, type: 'add' })) %>")
$("#modal_place").modal 'show'

# $('input#user_search').autocomplete
#   source: "/portal/associated_users/search"
#   minLength: 3
#   search: (event, ui) ->
#     $('#search-spinner').show()
#
#   open: (event, ui) ->
#     $('#search-spinner').hide()
#
#   select: (event, ui) ->
#     selected_option = ui.item.label
#     $.ajax
#       method: 'get'
#       url: "/portal/associated_users/new"
#       data:
#         user_id: ui.item.value
#         protocol_id: $('#add-user-form #protocol_id').val()
#       success: ->
#         Sparc.associated_users.showEpicRights($('.epic_access:checked:visible').val())
#
# close: ->
#   $('input#user_search').autocomplete('disable')
#   $('input#user_search').val('')
#   $('input#user_search').autocomplete('enable')

# FormFxManager.registerListeners($('#add-user-form'), Sparc.associated_users.display_dependencies);
