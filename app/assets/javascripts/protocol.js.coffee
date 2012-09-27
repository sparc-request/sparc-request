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

  $('.navigation_link').live 'click', ->
    location = $(this).attr('location')
    $('#location').val(location)
    $('#navigation_form').submit()
    console.log $(this).attr('location')
