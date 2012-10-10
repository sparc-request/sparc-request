$(document).ready ->
  $(document).ajaxError (event, request, settings) ->
    if request.statusText != 'abort'
      alert("An error happened processing your request: " + settings.url)

  $('.edit_project_role').live 'click', ->
    parent = $(this).attr('parent')
    project_role_id = $(this).attr('project_role_id')
    identity_id = $(this).attr('identity_id')
    $.ajax
      url: "/identities/#{identity_id}?project_role_id=#{project_role_id}"
      type: 'GET'
    console.log "about to edit"

  $('.add-user button').live 'click', ->
    $.ajax
      url: '/identities/add_to_protocol'
      type: 'POST'
      data: $('#identity_details :input').serialize()
    return false

  $('.restore_project_role').live 'click', ->
    parent = $(this).attr('parent')
    $(".#{parent}").css({opacity: 1})
    $(".#{parent} .actions").show()
    $(".#{parent} .restore").hide()
    $(".#{parent} input[name*='destroy']").val(false)

  $('.remove_project_role').live 'click', ->
    parent = $(this).attr('parent')
    $(".#{parent}").css({opacity: 0.5})
    $(".#{parent} .actions").hide()
    $(".#{parent} .restore").show()
    $(".#{parent} input[name*='destroy']").val(true)
