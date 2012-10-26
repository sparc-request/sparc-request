$(document).ready ->
  $(document).ajaxError (event, request, settings) ->
    if request.statusText != 'abort'
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

toggle_form_slide = ->
  if $('.ask-a-question-form-container').is(":visible")
    $('.up-carat').show()
    $('.down-carat').hide()
  else
    $('.up-carat').hide()
    $('.down-carat').show()

  $('.ask-a-question-form-container').slideToggle('slow', ->
    $('.your-email > input').focus()
  )

