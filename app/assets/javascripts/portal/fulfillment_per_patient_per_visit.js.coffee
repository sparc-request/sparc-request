$(document).ready ->

  Sparc.fulfillment_per_patient_per_visit = {
    ready: ->
      Sparc.fulfillment.displayDatesForUser($('.per_patient_per_visit_in_process_date.date, .per_patient_per_visit_complete_date.date'))

      $('.per_patient_per_visit input.update_on_change, select.billing_type.update_on_change').live('change', ->
        service = $(this).closest('.service')
        submitPerPatientPerVisitHash(service)
      )

      $('.per_patient_per_visit select.service_id.update_on_change').live('change', ->
        service                = $(this).closest('.service')
        service_select         = service.find("select:first")
        sub_service_request_id = service.find('.sub_service_request_id').val()
        old_service_id         = service_select.data('old_service_id')
        new_service_id         = service_select.val()
        subject_count          = service.find('.subject_count').val()
        service_request_id     = $('.add_service').data('service_request_id')
        is_duplicate           = Sparc.fulfillment_one_time_fees.isDuplicate(new_service_id) or false

        if !($(this).attr('class').search("service_id") == 0) || !(is_duplicate == true)
          hash =
            sub_service_request_id: sub_service_request_id,
            old_service_id        : old_service_id,
            new_service_id        : new_service_id,
            subject_count         : subject_count

          Sparc.fulfillment.submitHash(service_request_id, hash, 'change_line_item_service_and_quantity')
          service_select.data('old_service_id', new_service_id)
        else
          service_select.val(old_service_id)
          alert('Duplicate services cannot be added')
      )

      $('.open_close_visits').live('click', ->
        visits_list = $(this).closest('.service ul').siblings('ul.visits')
        triangle_1_s = $(this).siblings('.ui-icon-triangle-1-s')
        triangle_1_e = $(this).siblings('.ui-icon-triangle-1-e')
        triangle_1_e_search = $(this).attr('class').search('ui-icon-triangle-1-e')
        if visits_list.children().is(':visible') then visits_list.hide() else visits_list.show()
        $(this).toggle()
        if triangle_1_e_search > 0 then triangle_1_s.show() else triangle_1_e.show()
        triangle_1_s.css('display','inline-block') if $('.ui-icon-triangle-1-s').is(':visible')
      )

      $('.add_visit_button')
        .mouseenter (element) ->
          createVisitTip(element, 'add')
        .mousemove (element) ->
          $('#tip').css({ left: element.pageX + 0, top: element.pageY + 20 })
        .mouseleave ->
          $('#tip').remove()

      $('.remove_sub_item')
        .mouseenter (element) ->
          createVisitTip(element, 'remove')
        .mousemove (element) ->
          $('#tip').css({ left: element.pageX + 0, top: element.pageY + 20 })
        .mouseleave ->
          $('#tip').remove()

      $('.add_visit_button').live('click', ->
        services = $('.per_visit_services ul.service_list .service')
        visit_info = $(this).siblings('.visit_div').children('select.visit_num').val()
        visit_num = visit_info.match(/[0-9]+/)
        visit_selects = $('.add_visit_button').siblings('.visit_div').children('select.visit_num')
        quantity = $(this).siblings('.quantity_div').children('input.quantity').val()
        billing = $(this).siblings('.billing_div').children('select.billing_type').val()
        service_ul = $('.add_visit_button').closest('ul')
        visits_count = $('.visits_count').val()

        update_visits_count = parseInt(visits_count) + 1
        $('.visits_count').val(update_visits_count.toString())

        if visit_info.match('Add Visit')
          if $('ul.visits').find('li.visit:last').length > 0
            for last_li in $('ul.visits').find('li.visit:last')
              add_clone = $('.blank_visit li').clone(false)
              add_clone.find('strong').text("Visit #{visit_num}")
              add_clone.addClass("visit_#{visit_num}")
              add_clone.find('div:first').addClass("visit_text_#{visit_num}")
              add_clone.find('select.visit_num').val(visit_info)
              add_clone.find('select.billing_type').val(billing)
              add_clone.insertAfter($(last_li)).show()
          else
            add_clone = $('.blank_visit li').clone(false)
            add_clone.find('strong').text("Visit #{visit_num}")
            add_clone.addClass("visit_#{visit_num}")
            add_clone.find('div:first').addClass("visit_text_#{visit_num}")
            add_clone.find('select.visit_num').val(visit_info)
            add_clone.find('select.billing_type').val(billing)
            $('ul.visits').append(add_clone.show())


        else if visit_info.match('Insert Before')
          for insert_before_li in $('ul.visits').find("li.visit_#{visit_num}")
            clone = $('.blank_visit li').clone(false)
            clone.find('strong').text("Visit #{visit_num}")
            clone.addClass("visit_#{visit_num}")
            clone.find('div:first').addClass("visit_text_#{visit_num}")
            clone.find('select.visit_num').val(visit_info)
            # clone.find('input.quantity').val(quantity)
            clone.find('select.billing_type').val(billing)
            clone.insertBefore($(insert_before_li)).show()

            ibl = $(insert_before_li)
            ibl.find('strong').text("Visit #{parseInt(visit_num) + 1}")
            ibl.addClass("visit_#{parseInt(visit_num) + 1}")
            ibl.removeClass("visit_#{visit_num}")
            ibl.find('div:first').addClass("visit_text_#{parseInt(visit_num) + 1}")
            ibl.find('div:first').removeClass("visit_text_#{visit_num}")

            count = 2
            for visit in $(insert_before_li).nextAll('li.visit')
              v = $(visit)
              v.find('strong').text("Visit #{parseInt(visit_num) + count}")
              v.addClass("visit_#{parseInt(visit_num) + count}")
              v.removeClass("visit_#{parseInt(visit_num) + count - 1}")
              v.find('div:first').addClass("visit_text_#{parseInt(visit_num) + count}")
              v.find('div:first').removeClass("visit_text_#{parseInt(visit_num) + count - 1}")
              count++

        # for vs in visit_selects
        visit_selects.children('option:first').text("Add Visit #{parseInt($('.visits_count').val()) + 1}")
        visit_selects.append("<option>Insert Before Visit #{update_visits_count}</option>")

        $('.remove_visit_num').append("<option value='.visit_#{update_visits_count}'>Remove Visit #{update_visits_count}</option>")

        service_request_id = $('.add_service').data('service_request_id')
        sub_service_request_id = $('.add_service').data('sub_service_request_id')
        hash =
          sub_service_request_id: sub_service_request_id.replace('_', ''),
          visit_number: parseInt(visit_num) - 1

        Sparc.fulfillment.submitHash(service_request_id, hash, 'add_per_patient_per_visit_visit')

      )

      $('.remove_sub_item').live('click', ->
        if confirm("Are you sure?")
          services = $('.per_patient_per_visit')
          visit_div = $('.remove_visit_num').val()
          visit_num = visit_div.match(/[0-9]+/)
          visit_select = $('.add_visit_button').siblings('.visit_div').children('select.visit_num')
          remove_select = $('.remove_visit_num')
          visits_count = $('.visits_count').val()

          remove_these_visits = $(visit_div)

          update_visits_count = parseInt(visits_count) - 1
          $('.visits_count').val(update_visits_count.toString())

          for visit in $(visit_div)
            count = 0
            for visit_to_update in $(visit).nextAll('li.visit')
              v = $(visit_to_update)
              v.find('strong').text("Visit #{parseInt(visit_num) + count}")
              v.addClass("visit_#{parseInt(visit_num) + count}")
              v.removeClass("visit_#{parseInt(visit_num) + count + 1}")
              v.find('div:first').addClass("visit_text_#{parseInt(visit_num) + count}")
              v.find('div:first').removeClass("visit_text_#{parseInt(visit_num) + count + 1}")
              count++

          remove_these_visits.remove()

          remove_select.empty()
          visit_select.empty().append("<option>Add Visit #{update_visits_count + 1}</option>")

          i = 0
          while i < update_visits_count
            visit_select.append("<option>Insert Before Visit #{i+1}</option>")
            remove_select.append("<option value='.visit_#{i+1}'>Remove Visit #{i+1}</option>")
            i+=1

          service_request_id = $('.add_service').data('service_request_id')
          sub_service_request_id = $('.add_service').data('sub_service_request_id')
          hash =
            sub_service_request_id: sub_service_request_id.replace('_', ''),
            visit_number          : parseInt(visit_num) - 1

          Sparc.fulfillment.submitHash(service_request_id, hash, 'remove_per_patient_per_visit_visit')
      )

      $('.per_patient_per_visit_in_process_date, .per_patient_per_visit_complete_date').live('change', ->
        sub_service_request_id = $('.add_service').data('sub_service_request_id')
        service_request_id     = $('.add_service').data('service_request_id')
        in_process_date        = Sparc.fulfillment.readyMyDate($('.per_patient_per_visit_in_process_date').val(), 'send')
        complete_date          = Sparc.fulfillment.readyMyDate($('.per_patient_per_visit_complete_date').val(), 'send')
        hash =
          sub_service_request_id: sub_service_request_id,
          service_request_id: service_request_id,
          in_process_date: in_process_date,
          complete_date: complete_date

        Sparc.fulfillment.submitHash(service_request_id, hash, 'update_per_patient_per_visit_dates')
      )

      createVisitTip = (element, add_or_remove) ->
        if ($('#tip').length == 0) then $('<div>')
          .html("<span>Press here to #{add_or_remove} visit.</span>")
          .attr('id', 'tip')
          .css({ left: element.pageX + 30, top: element.pageY - 16 })
          .appendTo('body').fadeIn(1000)
        else null

      submitPerPatientPerVisitHash = (service) ->
        service_id = service.find('.service_id').val()
        sub_service_request_id = service.find('.sub_service_request_id').val()
        subject_count = service.find('.subject_count').val()
        optional = JSON.parse(service.find('.optional').val())
        service_request_id = $('.add_service').data('service_request_id')
        visits = []

        for visit in service.find('.visit')
          quantity_field = $(visit).find('.quantity')
          unless quantity_field.val().match(/[^0-9]/) or quantity_field.val() is ''
            quantity_field.data('old_quantity', quantity_field.val())
            visits.push({ quantity: parseInt(quantity_field.val()), billing: $(visit).find('.billing_type').val() })
          else
            quantity_field.val(quantity_field.data('old_quantity'))
            alert("Quantity must be an integer.")
            return

        hash =
          service_id            : service_id,
          sub_service_request_id: sub_service_request_id,
          subject_count         : subject_count,
          optional              : optional,
          visits                : visits

        Sparc.fulfillment.submitHash(service_request_id, hash, 'update_per_patient_per_visit_line_item')
  }
