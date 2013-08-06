$(document).ready ->
  $(document).ajaxError (event, request, settings, error) ->
    # If you're reading this and wondering why you are getting this
    # message I can't help you.  What I can do is give you a way around
    # it for custom errors. Set your response status to 418 which can be
    # found at:
    #   https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
    #
    # Alternatively, you can set global: false in your call to $.ajax.
    #
    # We also check to see if a _local_ error handler was given, in
    # which case it's likely we don't need to pop up the alert box,
    # because the error is already handled.
    #
    # TODO: Now that we are checking for a local error handler, we might
    # be able to remove some of these other conditions.
    #
    if request.status != 418 &&
       request.statusText != 'abort' &&
       settings.url != '/service_requests/feedback' &&
       !settings.error
      alert("An error happened processing your request: " + settings.url)

  $('.edit_project_role').live 'click', ->
    parent = $(this).attr('parent')
    identity_id = $(this).attr('identity_id')
    data = $(".#{parent} input").serialize()
    $.ajax
      url: "/identities/#{identity_id}?#{data}"
      type: 'GET'

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

  $('.ask-us-button').click ->
    toggle_form_slide()

  $(document).on('click', '.epic_access_radio_yes', ->
    pr_id = $(this).attr('project_role_id')
    show_epic_access(pr_id)
  )

  $(document).on('click', '.epic_access_edit', ->
    pr_id = $(this).attr('project_role_id')
    $("#epic_access_yes_#{pr_id}").click()
  )

show_epic_access = (project_role_id) ->
  $(".epic_access_dialog#project_role_#{project_role_id}").dialog({
    height: 425
    width: 500
    modal: true
    title: 'Access Rights'
    buttons:
      Ok: ->
        $(this).dialog('destroy')
  })


(exports ? this).toggle_form_slide = ->
  if $('.ask-a-question-form-container').is(":visible")
    $('.up-carat').show()
    $('.down-carat').hide()
  else
    $('#quick_question_email').val('')
    $('#quick_question_body').val('')
    $('.up-carat').hide()
    $('.down-carat').show()

  $('.ask-a-question-form-container').slideToggle('slow', ->
    $('.your-email > input').focus()
  )

