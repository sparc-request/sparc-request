#= require cart
#= require navigation

$(document).ready ->
  $('#select-type').change ->
    if $(this).val() == 'Yes'
      $('.existing-study').show()
      $('.existing-project').hide()
      $('#study-select #service_request_protocol_id').removeAttr('disabled')
      $('#project-select #service_request_protocol_id').attr('disabled', 'disabled')
    else
      $('.existing-project').show()
      $('.existing-study').hide()
      $('#project-select #service_request_protocol_id').removeAttr('disabled')
      $('#study-select #service_request_protocol_id').attr('disabled', 'disabled')

  $('.edit-study').button()
  $('.new-study').button()
  $('.edit-project').button()
  $('.new-project').button()

  $('.edit-study').click ->
    study_id = $('.edit_study_id').val()
    service_request_id = $('#service_request_id').val()
    window.location.href = "/service_requests/#{service_request_id}/studies/#{study_id}/edit"
    return false

  $('.edit-project').click ->
    console.log 'project click'
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
