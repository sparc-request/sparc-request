$ ->
  $(document).on 'click', '.delete-submission', ->
    id = $(this).data('id')
    lineItemId = $(this).data('line-item-id')
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
      if lineItemId != undefined && protocolId != undefined
        $.ajax
          type: 'DELETE'
          url: "/additional_details/submissions/#{id}?protocol_id=#{protocolId}&line_item_id=#{lineItemId}"
          success: ->
            swal('Deleted', 'Submission Deleted', "success")
      else
        $.ajax
          type: 'DELETE'
          url: "/additional_details/submissions/#{id}"
          success: ->
            swal('Deleted', 'Submission Deleted', "success")


