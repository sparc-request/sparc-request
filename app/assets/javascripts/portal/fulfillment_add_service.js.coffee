$(document).ready ->

  Sparc.fulfillment_add_service = {
    ready: ->
      $('.btn').button()

      $('.add_service').live('click', ->
        friendly_service_request_id = $(this).data('friendly_service_request_id')
        service_request_id          = $(this).data('service_request_id')
        subject_count               = parseInt($(this).data('subject_count'))
        sub_service_request_id      = $(this).data('sub_service_request_id').replace('_', '')
        selected_service            = $('#add_service_request_select :selected')
        service_id                  = selected_service.val()
        unit_minimum                = selected_service.data('unit_minimum')
        unit_factor                 = selected_service.data('unit_factor')
        is_one_time_fee             = selected_service.data('is_one_time_fee')
        is_duplicate                = Sparc.fulfillment_one_time_fees.isDuplicate(service_id) or false

        if is_duplicate is false
          if service_id isnt '' and is_one_time_fee is true
            $('.one_time_fee_services .blank_requests').remove()
            $('.one_time_fee_actions').show()

            unit_type     = selected_service.data('unit_type')
            service_clone = $('.one_time_fee_service_clone li.service').clone()
            cost          = selected_service.data('cost')
            service_clone.find('.cost_per_service').html("$#{cost.toFixed(2)}")
            service_clone.find('.service_quantity').data('service_cost', cost)
            service_clone.find('.quantity').val(unit_minimum)
            service_clone.find('.service_type').html("#{unit_type}")
            service_clone.find('select.service_id').data('old_service_id', service_id)
            service_clone.appendTo('.one_time_fee_services ul.service_list').show()
            service_clone.find('.service_id').attr('id', "service_#{service_id}").val(service_id).data('old_service_id', service_id)
            hash =
              service_request_id    : service_request_id,
              sub_service_request_id: sub_service_request_id,
              service_id            : service_id,
              in_process_date       : '',
              complete_date         : ''

            Sparc.fulfillment.submitHash(service_request_id, hash, 'add_one_time_fee_line_item')

            $('.in_process:last').datepicker(
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
              
            ).addClass('date')
            $('.complete:last').datepicker(
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
              
            ).addClass('date')

            $('.in_process:last, .complete:last').attr("readOnly", true)

          else if service_id isnt '' and is_one_time_fee is false
            per_visit_clone = $('.per_visit_service_clone .service').clone()
            per_visit_clone.find('select.update_on_change').data('old_service_id', service_id)
            $(per_visit_clone).appendTo('.per_visit_services .service_list')
            $('.per_visit_services .blank_requests').remove()
            $('.per_patient_per_visit_actions').show()

            per_visit_clone.find('.service_id').val(service_id)

            hash =
              service_request_id    : service_request_id,
              sub_service_request_id: sub_service_request_id,
              service_id            : service_id

            Sparc.fulfillment.submitHash(service_request_id, hash, 'add_per_patient_per_visit_line_item')

          $('#add_service_request_select').val('')
        else
          alert("Duplicate services cannot be added")
      )
  }
