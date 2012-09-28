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
