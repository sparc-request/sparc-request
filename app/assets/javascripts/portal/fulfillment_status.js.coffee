$(document).ready ->

  Sparc.fulfillment_status = {
    updatedableSSRAttrs: ['status', 'owner']
    serviceRequestId   : $("#service_request_id").val()
    subServiceRequestId: $("#sub_service_request_id").val()

    ready: ->
      Sparc.fulfillment_status.addAttrUpdaters()

      $('#sub_service_request_status').change ->
        if $(this).val() == 'draft'
          $('#service_request_owner').hide()
        else
          $('#service_request_owner').show()

    redrawStatusHistoryTable: (histories) ->
      historyTableBody = $('#status_history_table').children("tbody")
      historyTableBody.children("tr").remove()
      _.each(histories, (history) ->
        rowHtml = "<tr><td>#{history[0]}</td><td>#{history[1]}</td></tr>"
        historyTableBody.append(rowHtml)
      )

    updateStatusHistory: () ->
      ssrId = Sparc.fulfillment_status.subServiceRequestId
      srId = Sparc.fulfillment_status.serviceRequestId
      $.ajax({
        type: 'GET'
        url: "/portal/admin/service_requests/#{srId}/related_service_requests/#{ssrId}/status_history"
        dataType: 'json'
        contentType: 'application/json; charset=utf-8'
        success: (data) ->
          Sparc.fulfillment_status.redrawStatusHistoryTable(data)
      })

    addUpdaterToSelect: (attr) ->
      element = $("#sub_service_request_#{attr}")
      element.live('change', ->
        newAttrVal = element.val()
        attrData = {
          id: Sparc.fulfillment_status.subServiceRequestId
          service_request_id: Sparc.fulfillment_status.serviceRequestId
          attribute: {
            name: attr
            value: newAttrVal
          }
        }
        $("##{attr}-spinner").show()
        $.ajax({
          type: 'PUT'
          data: JSON.stringify(attrData)
          url: "/portal/admin/service_requests/#{Sparc.fulfillment_status.serviceRequestId}/related_service_requests/#{Sparc.fulfillment_status.subServiceRequestId}/update_attribute"
          dataType: 'json'
          contentType: 'application/json; charset=utf-8'
          success: (message) ->
            $("##{attr}-spinner").hide()
            $('.success_check').show().fadeOut(4000)
            Sparc.fulfillment_status.updateStatusHistory() if attr is "status"
        })
      )

    addAttrUpdaters: () ->
      Sparc.fulfillment_status.addUpdaterToSelect attr for attr in Sparc.fulfillment_status.updatedableSSRAttrs
  }
