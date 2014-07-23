# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  Sparc.related_service_requests = {
    ready: ->
      $(".rsr-dialog").dialog(
        autoOpen: false
        dialogClass: "rsr_dialog"
        modal: true
        minWidth: 325
        title: "Related Service Request Information"
      )

      $(".rsr-link").click ->
        ssr_id = this.id
        $(".rsr-dialog##{ssr_id}").dialog('open')
  }


