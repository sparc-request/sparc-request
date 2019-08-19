$(document).ready ->
  $(document).on 'submit', '#protocolMergeForm', (event) ->
    event.preventDefault()
    event.stopImmediatePropagation()

    master_protocol_id = $('#master_protocol').val()
    sub_protocol_id = $('#sub_protocol').val()

    data =
        'master_protocol_id'  : master_protocol_id,
        'sub_protocol_id'     : sub_protocol_id
    
    ConfirmSwal.fire(
      type: 'question'
      text: I18n.t('dashboard.protocol_merge.warning', master_protocol_id: master_protocol_id, sub_protocol_id: sub_protocol_id)
      confirmButtonText: I18n.t('dashboard.protocol_merge.yes_button')
      cancelButtonText: I18n.t('dashboard.protocol_merge.no_button')
    ).then (result) =>
      if result.value
        $.ajax
          type: 'PUT'
          url: "/dashboard/protocol_merge/perform_protocol_merge"
          data: data
          success: ->
            $('#master_protocol').val('')
            $('#sub_protocol').val('')
            $('#merge-button').removeAttr('disabled')
      else if result.dismiss == 'cancel'
        $('#merge-button').removeAttr('disabled')