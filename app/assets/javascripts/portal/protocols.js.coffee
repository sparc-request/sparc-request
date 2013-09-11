# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  Sparc.protocol = {
    ready: ->
      $('.permissions-dialog').dialog({
        autoOpen:false
        title: "User Rights"
        width: 400
        height: 300
        model: true
        buttons: {
          "Ok": () ->
            $(this).dialog('close')
        }
      })

      $('.protocol-information-button').live('click', ->
        if $(this).data('permission')
          protocol_id = $(this).data('protocol_id')
          window.location = "/portal/protocols/#{protocol_id}/edit"
        else
          $('.permissions-dialog').dialog('open')
          $('.permissions-dialog .text').html('Edit.')
      )

      $('.edit_service_request').live('click', ->
        if $(this).data('permission')
          window.location = $(this).data('url')
        else
          $('.permissions-dialog').dialog('open')
          $('.permissions-dialog .text').html('Edit.')
      )

      $('.service-request-button').live('click', ->
        if $(this).data('permission')
          window.location = $(this).data('url')
        else
          $('.permissions-dialog').dialog('open')
          $('.permissions-dialog .text').html('Edit.')
      )


      $('.view-sub-service-request-button').live('click', ->
        id = $(this).data('service_request_id')
        protocol_id = $(this).data('protocol_id')
        status = $(this).data('status')
        ssr_id = $(this).attr('data-ssr_id')
        random_number = Math.floor(Math.random()*10101010101)
        $.ajax({
            method: 'get'
            url: "/portal/service_requests/#{id}?#{random_number}"
            data: {protocol_id: protocol_id, status: status, ssr_id: ssr_id}
            success: ->
              $('.view-sub-service-request-dialog').dialog('open')
          })
      )

      $('.edit-protocol-information-dialog').dialog({
          autoOpen: false
          title: 'Edit Study Information'
          width: 715
          height: 500
          modal: true
          buttons: {
            "Submit": () ->
              disableButton()
              form = $('.edit-protocol-information-dialog').children('form')
              form.bind('ajax:success', (data) ->
                enableButton()
                $('.edit-protocol-information-dialog').dialog('close')
                Sparc.protocol.renderProtocolAccordionList()
              ).submit()
            "Cancel": () ->
              $(this).dialog('close')
          }
      })

      $('.view-sub-service-request-dialog').dialog({
          autoOpen: false
          title: 'Service Information'
          width: 715
          height: 500
          modal: true
          buttons: {
            "Ok": () ->
              $(this).dialog('close')
          }
      })

      $('.view-full-calendar-button').live('click', ->
        protocol_id = $(this).data('protocol_id')
        $.ajax({
            method: 'get'
            url: "/portal/protocols/#{protocol_id}/view_full_calendar"
            success: ->
              $('.view-full-calendar-dialog').dialog('open')
          })
      )

      $('.view-full-calendar-dialog').dialog({
          autoOpen: false
          title: 'Study Information'
          width: 715
          height: 500
          modal: true
          buttons: {
            "Ok": () ->
              $(this).dialog('close')
          }
      })


      # Sparc.protocol.renderProjectAccordionList()
      load_Page = -> Sparc.protocol.renderProtocolAccordionList()
      setTimeout load_Page, 2000

      $('#productivity-accordion').accordion({
        heightStyle: 'content'
        event: 'mouseover'
        collapsible: true
      })

      $('.draggable')
        .draggable({
          containment: 'document'
          appendTo: 'body'
          helper: 'clone'
          cursor: 'url(closedhand.cur),move'
          cursorAt: {left: 5}
          revert: 'invalid'
        })
        .mouseenter (element) ->
          createTip(element) unless $(this).hasClass('ui-draggable-disabled')
        .mousemove (element) ->
          $('#tip').css({ left: element.pageX + 30, top: element.pageY - 16 })
        .mouseleave ->
          $('#tip').remove()

      $('.droppable').droppable({
        tolerance: 'touch'
        activeClass: 'drop-active'
        hoverClass: 'drop-hover'
        drop: (event, ui) ->
          element = $(ui.draggable).clone()
          switch element.data('type')
            when 'grant' then $(this).children('.grants-list').append(element)
            when 'publication' then $(this).children('.publications-list').append(element)
            else null
          ui.draggable.draggable('disable')
      })

      $('#previous').live('click', ->
        Sparc.protocol.navigateCostTable('decrease') unless $(this).attr('disabled') == 'disabled'
      )

      $('#next').live('click', ->
        Sparc.protocol.navigateCostTable('increase') unless $(this).attr('disabled') == 'disabled'
      )

      $('.blue-provider').live('click', ->
        protocol_id = $(this).data('protocol_id')
        visible = if $(this).children('.ui-icon').hasClass('ui-icon-triangle-1-s') then true else false
        if visible && $(this).siblings(".protocol-information-#{protocol_id}").children('.protocol-information-title').length == 0
          Sparc.protocol.renderProtocolAccordionTab(protocol_id)
      )

    disableButton: (containing_text, change_to) ->
      button = $(".ui-dialog .ui-button:contains(#{containing_text})")
      button.html("<span class='ui-button-text'>#{change_to}</span>")
        .attr('disabled',true)
        .addClass('button-disabled')

    enableButton: (containing_text, change_to) ->
      button = $(".ui-dialog .ui-button:contains(#{containing_text})")
      button.html("<span class='ui-button-text'>#{change_to}</span>")
        .attr('disabled',false)
        .removeClass('button-disabled')

    navigateCostTable: (direction) ->
      visitsArray = JSON.parse($('#visits_array').val())
      visit_group_num = parseInt($('#visit_group_num').val())
      if direction == 'increase'
        visit_group_num += 1 unless visit_group_num == (visitsArray.length - 1)
      else if direction == 'decrease'
        visit_group_num -= 1 unless visit_group_num == 0
      Sparc.protocol.disableButton(">",">") if visit_group_num == (visitsArray.length - 1)
      Sparc.protocol.enableButton(">",">") if visit_group_num < (visitsArray.length - 1)
      Sparc.protocol.disableButton("<","<") if visit_group_num == 0
      Sparc.protocol.enableButton("<","<") if visit_group_num > 0
      $('.visit_quantity').html('')
      $('.visit_header').html('')
      i = 0
      for item in visitsArray[visit_group_num]
        i += 1
        $("#column_#{i}").html(item.visit_num)
        for visit in item.values
          display_cost = visit.cost / 100
          _display_cost = if isNaN(display_cost)
            "N/A"
          else
            '$' + display_cost.toFixed(2)
          $("#quantity_#{visit.service_id}_column_#{i}").html(_display_cost)
      $('#visit_group_num').val(visit_group_num)

    renderProtocolAccordionList: ->
      $('.loading_protocol').show()
      $('#protocol-accordion').html('')
      default_protocol = $('.default_protocol').val()
      url = if default_protocol == "" then "/portal/protocols" else "/portal/protocols?default_protocol=#{default_protocol}"
      $.ajax({
        method: 'get'
        url: url
        success: ->
          $('.search_protocols').show()
          $('.loading_protocol').hide()
          $('.btn').button()
          $('.blue-provider:first').trigger('click')
      })

    renderProtocolAccordionTab: (protocol_id) ->
      $(".protocol-information-#{protocol_id}").html("<img src='/assets/portal/spinner.gif' alt='Spinner'><br />Please be patient while the protocol/study loads.")
      random_number = Math.floor(Math.random()*10101010101)
      $.ajax({
        method: 'get'
        url: "/portal/protocols/#{protocol_id}?#{random_number}"
        success: ->
          $('.btn').button()
        error: (xhr, j_status, error_thrown) ->
          $(".protocol-information-#{protocol_id}").html('')
      })
  }
