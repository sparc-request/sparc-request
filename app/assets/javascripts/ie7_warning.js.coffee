$(document).ready ->
  $('#ie7_warning').dialog({
    autoOpen: true
    dialogClass: "ie_warning"
    title: 'Warning'
    width: 750
    modal: true
    resizable: false
    buttons:
        Ok: ->
          $(this).dialog('close')
  })
  $('.ie_warning').css('z-index', '5000')