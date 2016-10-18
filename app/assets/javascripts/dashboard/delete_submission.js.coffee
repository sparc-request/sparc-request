$ ->
  $(document).on 'click', '.delete-submission', ->
    id = $(this).data('id')
    serviceId = $(this).data('service-id')
    srId = $(this).data('sr-id')
    protocolId = $(this).data('protocol-id')
    swal {
      title: 'Are you sure?'
      text: 'You cannot undo this action'
      type: 'warning'
      showCancelButton: true
      confirmButtonColor: '#DD6B55'
      confirmButtonText: 'Delete'
      closeOnConfirm: true
    }, ->
      if srId != undefined && protocolId != undefined
        $.ajax
          type: 'DELETE'
          url: "/services/#{serviceId}/additional_details/submissions/#{id}?protocol_id=#{protocolId}&sr_id=#{srId}"
          success: ->
            swal('Deleted', 'Submission Deleted', "success")
      else
        $.ajax
          type: 'DELETE'
          url: "/services/#{serviceId}/additional_details/submissions/#{id}"
          success: ->
            swal('Deleted', 'Submission Deleted', "success")


