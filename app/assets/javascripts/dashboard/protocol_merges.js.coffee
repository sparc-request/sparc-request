$ ->

  $(document).on 'click', '#merge-button', ->
    master_protocol_id = $('#master_protocol').val()
    sub_protocol_id = $('#sub_protocol').val()

    data =
        'master_protocol_id'  : master_protocol_id,
        'sub_protocol_id'     : sub_protocol_id
        
    if confirm("Preparing to merge protocol #{master_protocol_id} and protocol #{sub_protocol_id}. Do you wish to continue?")
      $.ajax
          type: 'GET'
          url: "/dashboard/protocol_merge/perform_protocol_merge"
          data: data
          success: ->
            $('#master_protocol').val('')
            $('#sub_protocol').val('')
