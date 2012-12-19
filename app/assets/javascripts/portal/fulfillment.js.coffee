$(document).ready ->

  Sparc.fulfillment = {
    ready: ->

      $('select.service_id').live('change', ->
        $(this).attr('id',"service_#{$(this).val()}")
        service_id    = $(this).val()
        cost          = $("select#service_#{service_id} option:selected").data('cost')
        quantity      = $(this).closest('li').find('.service_quantity').val()
        adjusted_cost = Sparc.fulfillment.multiplyByQuantity(quantity, cost)
        unit_type     = $("select#service_#{service_id} option:selected").data('unit_type')
        $(this).closest('li').find('.cost_per_service').html("$#{adjusted_cost.toFixed(2)}")
        $(this).closest('li').find('.service_type').text(unit_type)
      )

      $('.remove_service').live('click', ->
        if confirm("Are you sure?")
          service_type       = $(this).data('service_type')
          services_selected  = $(this).closest('.services-selected')
          service_id         = $(this).siblings('div').find('.service_id').val()
          service_request_id = $('.add_service.btn').data('service_request_id')

          $(this).closest('.service').remove()
          if services_selected.find(".service_list .#{service_type}").length == 0
            string = if service_type == 'one_time_fee' then 'one time fee' else 'per-patient per-visit'
            services_selected.find('.service_list').prepend("<div class='blank_requests'>There are no #{string} requests.</div>")
            if service_type == 'per_patient_per_visit'
              $('.per_patient_per_visit_actions').hide()
            else if service_type == 'one_time_fee'
              $('.one_time_fee_actions').hide()

          hash = { service_id: service_id }
          Sparc.fulfillment.submitHash(service_request_id, hash, 'delete_line_item')
      )

    pushFulfillment: (fulfillment, date, time, timeframe, notes) ->
      fulfillment.push({date: "#{date}", time: "#{time}", timeframe: "#{timeframe}", notes: "#{notes}"})

    calculateTime: (time, timeframe) ->
      switch timeframe
        when 'Days'
          time * (24 * 60)
        when 'Hours'
          time * 60
        else
          time

    readyMyDate: (date_string, action) ->
      return "" unless date_string
      if action is 'send'
        [garbage, month, day, year] = date_string.match(/(\d)\/(\d?\d)\/(\d{4})/)
        formatted_month = if(month.length < 2) then ("0" + month) else month
        "#{year}-#{formatted_month}-#{day}"

      else
        old_format      = /(\d?\d)\/(\d?\d)\/(\d{4})/
        from_db_format = /(\d{4})-(\d\d)-(\d\d)/
        if date_string.match(old_format)
          [garbage, month, day, year] = date_string.match(old_format)
        else
          [garbage, year, month, day] = date_string.match(from_db_format)
        month_int = parseFloat(month)
        formatted_month = if(month_int < 10) then month.charAt(1) else month
        "#{formatted_month}/#{day}/#{year}"

    displayDatesForUser: (date_elements) ->
      for date in date_elements
        $(date).val(Sparc.fulfillment.readyMyDate($(date).val(), 'view'))

    multiplyByQuantity: (quantity, cost) ->
      if cost == 'N/A'
        cost
      else
        quantity * cost

    readElement: (element) ->
      if string = element.val()
        if float = Sparc.fulfillment.replaceNonNumerics(string)
          Math.round(100 * parseFloat(float))

    replaceNonNumerics: (string) ->
      match = string.match /^[^\d\.]*([\d,]+(\.\d+)?|\.\d+)[^\d\.]*$/
      match[1].replace(/,/g,'')

    calculateSubsidyPercentage: (total_cost, pi_contribution) ->
      points = 100 * ((total_cost - pi_contribution) / total_cost)
      rounded = Math.round(points * 10)
      whole_points = Math.floor(rounded / 10)
      s = "#{whole_points}"
      if rounded % 10 > 0
        s += "." + rounded % 10
      if total_cost > 0 then "#{s}%" else 0

    calculatePiContribution: (total_cost, subsidy_percent) ->
      amount = ((((subsidy_percent / 100) * total_cost) - total_cost) * -1) / 100
      rounded = Math.round(amount * 10)
      whole_points = Math.floor(rounded / 10)
      "#{whole_points}"

    submitHash: (service_request_id, hash, method_call) ->
      $.ajax
        type: 'PUT'
        url: "/portal/admin/service_requests/#{service_request_id}/#{method_call}"
        data: JSON.stringify(hash)
        dataType: 'json'
        contentType: 'application/json; charset=utf-8'
        success: (message) ->
          $('.success_check').show().fadeOut(4000)

  }
