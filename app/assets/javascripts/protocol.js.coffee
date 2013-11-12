#= require cart
#= require navigation

$(document).ready ->
  $("input[name=protocol]:radio").change ->
    if $(this).val() == 'Research Study'
      $('.existing-study').show()
      $('.edit-study').show() unless $('.edit_study_id').val() == ""
      $('.existing-project').hide()
      $('#study-select #service_request_protocol_id').removeAttr('disabled')
      $('#project-select #service_request_protocol_id').attr('disabled', 'disabled')
    else
      $('.existing-project').show()
      $('.edit-project').show() unless $('.edit_project_id').val() == ""
      $('.existing-study').hide()
      $('#project-select #service_request_protocol_id').removeAttr('disabled')
      $('#study-select #service_request_protocol_id').attr('disabled', 'disabled')

  $("input[name=protocol]:radio").each (index, element) =>
    if $(element).is(':checked')
      $(element).change()

  $('.edit-study').button()
  $('.edit-study').hide() unless $('.edit_study_id').val() != ""
  $('.new-study').button()
  $('.edit-project').button()
  $('.edit-project').hide() unless $('.edit_project_id').val() != ""
  $('.new-project').button()

  $('.edit_study_id').change ->
    if ($(this).val() == "")
      $('.edit-study').hide()
    else
      $('.edit-study').show()

  $('.edit_project_id').change ->
    if ($(this).val() == "")
      $('.edit-project').hide()
    else
      $('.edit-project').show()

  $('.edit-study').click ->
    study_id = $('.edit_study_id').val()
    service_request_id = $('#service_request_id').val()
    window.location.href = "/service_requests/#{service_request_id}/studies/#{study_id}/edit"
    return false

  $('.edit-project').click ->
    project_id = $('.edit_project_id').val()
    service_request_id = $('#service_request_id').val()
    window.location.href = "/service_requests/#{service_request_id}/projects/#{project_id}/edit"
    return false

  $('#infotip').qtip
    content: 'Research Study: An individual research study with defined aims and outcomes'
    position:
      corner:
        target: "topRight"
        tooltip: "bottomLeft"
        
    style:
      tip: true
      border:
        width: 0
        radius: 4

      name: "light"
      width: 250

  $('#ctrc_dialog').dialog
    modal: true
    width: 375
    height: 200

  $('#redirect').button()