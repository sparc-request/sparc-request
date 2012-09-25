loadDescription = (url) ->
  $.ajax
    type: 'POST'
    url: url

addService = (id) ->
  $.ajax
    type: 'POST'
    url: "/service_requests/#{id}/add_service"

removeService = (id) ->
  $.ajax
    type: 'POST'
    url: "/service_requests/#{id}/remove_service"

$(document).ready ->
  $('#institution_accordion').accordion
    autoHeight: false
    collapsible: true
    change: (event, ui)->
      if url = (ui.newHeader.find('a').attr('href') or ui.oldHeader.find('a').attr('href'))
        loadDescription(url)

  $('.provider_accordion').accordion
    autoHeight: false
    collapsible: true
    change: (event, ui)->
      if url = (ui.newHeader.find('a').attr('href') or ui.oldHeader.find('a').attr('href'))
        loadDescription(url)
  

  $('.title .name a').live 'click', ->
    $(this).parents('.title').siblings('.service-description').toggle()

  $('.add_service').live 'click', ->
    id = $(this).attr('id')
    addService(id)

  $('.remove-button').live 'click', ->
    $(this).hide()
    id = $(this).attr('id')
    removeService(id)


