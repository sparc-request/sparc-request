$ ->

  $(document).on('submit', '#protocolMergeForm', (event) ->
    event.preventDefault()
    master_protocol_id = $('#master_protocol').val()
    sub_protocol_id = $('#sub_protocol').val()

    data =
        'master_protocol_id'  : master_protocol_id,
        'sub_protocol_id'     : sub_protocol_id

    ConfirmSwal.fire(
      type: 'question'
      text: I18n.t('dashboard.protocol_merge.warning', master_protocol_id: "<%= master_protocol_id %>", sub_protocol_id: "<%= sub_protocol_id %>" )
      # title: I18n.t('proper.catalog.new_request.header')
      text: I18n.t('proper.catalog.new_request.warning')
      confirmButtonText: I18n.t('dashboard.protocol_merge.yes_button')
      cancelButtonText: I18n.t('dashboard.protocol_merge.no_button')
    ).then (result) =>
      if result.value
        $.ajax
          type: 'GET'
          url: "/dashboard/protocol_merge/perform_protocol_merge"
          data: data
          success: ->
            $('#master_protocol').val('')
            $('#sub_protocol').val('')
    #   else if result.dismiss == 'cancel'
    #     window.location = "<%= dashboard_root_path %>"
    # <% elsif @duplicate_service %>
    # AlertSwal.fire(
    #   type: 'error'
    #   title: I18n.t('proper.cart.duplicate_service.header')
    # )

