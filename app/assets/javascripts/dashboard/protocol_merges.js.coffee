$ ->

  $(document).on 'click', '#merge-button', ->
    master_protocol_id = $('#master_protocol').val()
    sub_protocol_id = $('#sub_protocol').val()

    data =
        'master_protocol_id'  : master_protocol_id,
        'sub_protocol_id'     : sub_protocol_id
    $.ajax
          type: 'GET'
          url: "/dashboard/protocol_merge/perform_protocol_merge"
          data: data
