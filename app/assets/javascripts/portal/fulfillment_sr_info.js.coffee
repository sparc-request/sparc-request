$(document).ready ->

  Sparc.fulfillment_sr_info = {

    ready: ->
      Sparc.fulfillment.displayDatesForUser($('.date'))

      $('.requester_contacted_date, .consult_arranged_date').live('change', ->
        rcd_string = $('.requester_contacted_date').val()
        cad_string = $('.consult_arranged_date').val()

        requester_contacted_date = Sparc.fulfillment.readyMyDate(rcd_string, 'send')
        consult_arranged_date    = Sparc.fulfillment.readyMyDate(cad_string, 'send')

        sub_service_request_id = $(this).data('sub_service_request_id')
        service_request_id = $('.add_service').data('service_request_id')
        hash =
          requester_contacted_date: requester_contacted_date,
          consult_arranged_date   : consult_arranged_date,
          sub_service_request_id  : sub_service_request_id

        Sparc.fulfillment.submitHash(service_request_id, hash, 'update_requester_contacted_and_consult_arranged_dates')
      )

      $('.proposed_start_date, .proposed_end_date').live('change', ->
        psd_string = $('.proposed_start_date').val()
        ped_string = $('.proposed_end_date').val()

        proposed_start_date = Sparc.fulfillment.readyMyDate(psd_string, 'send')
        proposed_end_date   = Sparc.fulfillment.readyMyDate(ped_string, 'send')

        sub_service_request_id = $(this).data('sub_service_request_id')
        service_request_id     = $('.add_service').data('service_request_id')
        hash =
          proposed_start_date   : proposed_start_date,
          proposed_end_date     : proposed_end_date,
          sub_service_request_id: sub_service_request_id

        Sparc.fulfillment.submitHash(service_request_id, hash, 'update_proposed_start_stop_dates')
      )

      $('.pi-contribution').live('keyup', ->
        cost_string = Sparc.fulfillment.replaceNonNumerics($(this).data('total_cost'))
        total_cost = 100 * parseFloat(cost_string)
        contribution_amount = Sparc.fulfillment.readElement($(this))
        if $(this).val() is "" or $(this).val() is "$"
          percentage = ""
        else
          percentage = Sparc.fulfillment.calculateSubsidyPercentage(total_cost, contribution_amount)
        $('.subsidy').val(percentage)
      )

      $('.pi-contribution').live('change', ->
        service_request_id      = $('.add_service').data('service_request_id')
        sub_service_request_id  = $(this).data('sub_service_request_id')
        subsidy_id              = $(this).data('program_or_core_id')
        subsidy_amount_in_cents = $(this).val() * 100
        hash =
          sub_service_request_id : sub_service_request_id,
          subsidy_id             : subsidy_id,
          subsidy_amount_in_cents: subsidy_amount_in_cents

        value = $(this).val()
        if value.indexOf('$') == -1
          $(this).val("$#{value}")

        Sparc.fulfillment.submitHash(service_request_id, hash, 'update_subsidy_amount')
      )

      $('.subsidy').live('keyup', ->
        cost_string         = Sparc.fulfillment.replaceNonNumerics($('.pi-contribution').data('total_cost'))
        total_cost          = 100 * parseFloat(cost_string)
        subsidy_percent     = parseFloat(Sparc.fulfillment.replaceNonNumerics($(this).val()))
        contribution_amount = Sparc.fulfillment.calculatePiContribution(total_cost, subsidy_percent)
        $('.pi-contribution').val("$#{contribution_amount}")
      )

      $('.subsidy').live('change', ->
        service_request_id      = $('.add_service').data('service_request_id')
        sub_service_request_id  = $('.pi-contribution').data('sub_service_request_id')
        subsidy_id              = $('.pi-contribution').data('program_or_core_id')
        pi_contr_string         = Sparc.fulfillment.replaceNonNumerics($('.pi-contribution').val())
        subsidy_amount_in_cents = parseFloat(pi_contr_string) * 100
        hash =
          sub_service_request_id : sub_service_request_id,
          subsidy_id             : subsidy_id,
          subsidy_amount_in_cents: subsidy_amount_in_cents

        Sparc.fulfillment.submitHash(service_request_id, hash, 'update_subsidy_amount')
      )
  }
