# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

loadDescription = (url) ->
  $.ajax
    type: 'POST'
    url: url

$(document).ready ->
  $(document).ajaxError ->
      alert("Connection to the server has been terminated and/or failed.  Data may have been lost")

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
