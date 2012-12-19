$(document).ready ->
  Sparc.fulfillment_one_time_fees = {
    ready: ->
      Sparc.fulfillment.displayDatesForUser($('.in_process.date, .complete.date, .fulfillment .date'))

      $('.non_per_patient_per_visit div input, .non_per_patient_per_visit select.timeframe, .fulfillment li .date, .timeframe, .notes').live('change', ->
        submitOneTimeVisitHash($(this).closest('.service'))
      )

      $('.non_per_patient_per_visit select.service_id').live('change', ->
        old_service_id = $(this).data('old_service_id')
        service_id     = $(this).val()
        is_duplicate   = Sparc.fulfillment_one_time_fees.isDuplicate(service_id) or false

        unless is_duplicate is true
          submitOneTimeVisitHash($(this).closest('.service'))
        else
          $(this).val(old_service_id)
          alert('Duplicate services cannot be added')
      )

      $('.fulfillment input.time').live('change', ->
        if $(this).val().match(/[a-zA-Z]/) || $(this).val() == ''
          alert('Quantity must be a number.')
          $(this).val($(this).data('old_value'))
        else
          $(this).data('old_value', $(this).val())
          submitOneTimeVisitHash($(this).closest('.service'))
      )

      $('.service_quantity').live('change', ->
        service_id = $(this).closest('li').find('select.service_id').val()
        cost = $("select#service_#{service_id} option:selected").data('cost')
        unit_factor = $("select#service_#{service_id} option:selected").data('unit_factor')
        adjusted_cost = calculatePerUnitCost(unit_factor, $(this).val(), cost) * $(this).val()
        $(this).closest('li').find('.cost_per_service').html("$#{adjusted_cost.toFixed(2)}")
      )

      calculatePerUnitCost = (unit_factor, quantity, package_cost) ->
        if package_cost == 'N/A'
          package_cost
        else
          units_per_package = (unit_factor or 1)
          units_we_want = quantity
          packages_we_have_to_get = Math.ceil(units_we_want / units_per_package)
          total_cost = packages_we_have_to_get * package_cost
          if units_we_want == 0
            0
          else
            total_cost / units_we_want

      $('.open_close_fulfillment').live('click', ->
        fulfillment_list = $(this).closest('.service ul').siblings('span.fulfillments')
        triangle_1_s = $(this).siblings('.ui-icon-triangle-1-s')
        triangle_1_e = $(this).siblings('.ui-icon-triangle-1-e')
        triangle_1_e_search = $(this).attr('class').search('ui-icon-triangle-1-e')
        if fulfillment_list.children().is(':visible') then fulfillment_list.hide() else fulfillment_list.show()
        $(this).toggle()
        if triangle_1_e_search > 0 then triangle_1_s.show() else triangle_1_e.show()
        triangle_1_s.css('display','inline-block') if $('.ui-icon-triangle-1-s').is(':visible')
      )

      $('.new_fulfillment').live('click', ->
        fulfillment_ul = $(this).prev()
        $('.blank_fulfillment li').find('input.date').val('').removeAttr('id')
        $('.blank_fulfillment li').find('input.time').removeAttr('id')
        $('.blank_fulfillment li').find('input.notes').val('').removeAttr('id')
        $('.blank_fulfillment li').clone(false).appendTo(fulfillment_ul).show()
        $('.date').removeClass('hasDatepicker').datepicker
          constrainInput: true
          dateFormat: "m/dd/yy"
          changeMonth: true
          changeYear: true
          showButtonPanel: true
          beforeShow: (input) ->
            callback = ->
              buttonPane = $(input).datepicker( "widget" ).find( ".ui-datepicker-buttonpane" )
              $( "<button>", {
                class: "ui-state-default ui-priority-primary ui-corner-all"
                text: "Clear"
                click: ->
                  $.datepicker._clearDate(input)
              }).appendTo(buttonPane)
            setTimeout( callback, 1)
          
        $('.date').attr("readOnly", true)
      )

      $('.remove_fulfillment').live('click', ->
        if confirm("Are you sure?")
          closest_service = $(this).closest('.service')
          $(this).closest('li').remove()
          submitOneTimeVisitHash(closest_service)
      )

      submitOneTimeVisitHash = (service) ->
        service_span   = service.children('span')
        service_ul     = service.children('ul')
        sub_service_request_id = service_ul.find('.sub_service_request_id').val()
        old_service_id = service_ul.find('.service_id').data('old_service_id')
        new_service_id = service_ul.find('.service_id').val()
        old_service_id = new_service_id unless old_service_id
        quantity_field = service_ul.find('.quantity')
        quantity       = quantity_field.val()
        in_process     = Sparc.fulfillment.readyMyDate(service_ul.find('.in_process.date').val(), 'send')
        complete       = Sparc.fulfillment.readyMyDate(service_ul.find('.complete.date').val(), 'send')

        fulfillment = []
        unless quantity.match(/[\D]/) || quantity == ''
          for li in service_span.find('.fulfillment li')
            timeframe = $(li).find('.timeframe').val()
            date      = Sparc.fulfillment.readyMyDate($(li).find('.date').val(), 'send')
            time      = Sparc.fulfillment.calculateTime($(li).find('.time').val(), timeframe)
            notes     = $(li).find('.notes').val()
            Sparc.fulfillment.pushFulfillment(fulfillment, date, time, timeframe, notes)

          hash =
            sub_service_request_id: sub_service_request_id,
            new_service_id        : new_service_id,
            old_service_id        : old_service_id,
            quantity              : parseInt(quantity),
            fulfillment           : fulfillment,
            in_process            : in_process,
            complete              : complete

          service_request_id = $('.add_service').data('service_request_id')
          Sparc.fulfillment.submitHash(service_request_id, hash, 'update_one_time_fee_line_item')
          quantity_field.data('old_quantity', quantity)

          service_ul.find('.service_id').data('old_service_id', new_service_id)
        else
          quantity_field.val(quantity_field.data('old_quantity'))
          alert("Quantity can only be a number.")
          quantity_field.focus()

    isDuplicate: (service_id) ->
      for service_field in $('.service_id')
        return true if $(service_field).data('old_service_id') is service_id

  }
