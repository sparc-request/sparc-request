$ ->
  $(document).on 'click', '.delete-submission', ->
    id = $(this).data('id')
    serviceId = $(this).data('service-id')
    lineItemId = $(this).data('line-item-id')
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
      if lineItemId != undefined && protocolId != undefined
        $.ajax
          type: 'DELETE'
          url: "/services/#{serviceId}/additional_details/submissions/#{id}?protocol_id=#{protocolId}&line_item_id=#{lineItemId}"
          success: ->
            swal('Deleted', 'Submission Deleted', "success")
      else
        $.ajax
          type: 'DELETE'
          url: "/services/#{serviceId}/additional_details/submissions/#{id}"
          success: ->
            swal('Deleted', 'Submission Deleted', "success")


