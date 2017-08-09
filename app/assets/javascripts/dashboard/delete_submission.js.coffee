$ ->
  $(document).on 'click', '.delete-submission', ->
    id = $(this).data('id')
    ssrId = $(this).data('ssr-id')
    protocolId = $(this).data('protocol-id')
    swal {
      title: I18n['swal']['swal_confirm']['title']
      text: I18n['swal']['swal_confirm']['text']
      type: 'warning'
      showCancelButton: true
      confirmButtonColor: '#DD6B55'
      confirmButtonText: 'Delete'
      closeOnConfirm: true
    }, ->
      if ssrId != undefined && protocolId != undefined
        $.ajax
          type: 'DELETE'
          url: "/additional_details/submissions/#{id}?protocol_id=#{protocolId}&ssr_id=#{ssrId}"
          success: ->
            swal('Deleted', 'Submission Deleted', "success")
      else
        $.ajax
          type: 'DELETE'
          url: "/additional_details/submissions/#{id}"
          success: ->
            swal('Deleted', 'Submission Deleted', "success")


