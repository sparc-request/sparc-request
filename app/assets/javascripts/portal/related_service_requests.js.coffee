# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $('.delete-ssr-button').click ->
    if confirm("Are you sure")
      $('.delete-ssr-indicator').show()
      sub_service_request_id = $(this).attr('data-sub_service_request_id')
      $.ajax({
        type: 'DELETE'
        url: "/portal/admin/sub_service_requests/#{sub_service_request_id}"
        dataType: 'script'
        contentType: 'application/json; charset=utf-8'
      })

  Sparc.related_service_requests = {
    ready: ->
      $(".rsr-dialog").dialog(
        autoOpen: false
        modal: true
        minWidth: 325
        title: "Related Service Request Information"
      )

      $(".rsr-link").click ->
        ssr_id = this.id
        $(".rsr-dialog##{ssr_id}").dialog('open')
  }


