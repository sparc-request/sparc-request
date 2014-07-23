$(document).ready ->
  Sparc.admin = {
    ready: ->
      $('#service_request_workflow_states').change ->
        $('.services').hide()
        $(".#{$(this).val()}").show()
        Sparc.admin.stripify_table()

      if $('.search-all-service-requests').length > 0
        $('.search-all-service-requests').autocomplete({
          source: JSON.parse($('.values_test').val())
          select: (event, ui) ->
            $('.services').hide()
            $(".#{ui.item.id}").show()
            $('#admin-tablesorter').tablesorter({sortList:[[0,1]]})
            Sparc.admin.stripify_table()
        })

      $('.search-all-service-requests').focus ->
        $(this).val('')

      $('.search-all-service-requests').live('keyup', ->
        $('#service_request_workflow_states').change() if $(this).val() is ''
      ).live('click', ->
        $('#service_request_workflow_states').change() if $(this).val() is ''
      )

      Sparc.admin.sortify_tables()
      Sparc.admin.clickify_table_datas()
      Sparc.admin.clickify_cwf_table_datas()

      $('#service_request_workflow_states').change()

      $('.upload-document').click ->
        $('#upload-spinner').show()

      $('.open_close_services').live('click', ->
        services_rest = $(this).closest('.services_first').siblings('.services_rest')
        triangle_1_s = $(this).siblings('.ui-icon-triangle-1-s')
        triangle_1_e = $(this).siblings('.ui-icon-triangle-1-e')
        triangle_1_e_search = $(this).attr('class').search('ui-icon-triangle-1-e')
        if services_rest.children().is(':visible') then services_rest.hide() else services_rest.show()
        $(this).toggle()
        if triangle_1_e_search > 0 then triangle_1_s.show() else triangle_1_e.show()
        triangle_1_s.css('display','inline-block') if $('.ui-icon-triangle-1-s').is(':visible')
      )

    stripify_table: () ->
      rows = $('.admin-index-ssr-list tbody tr:visible')
      $("table#admin-tablesorter tr.even").removeClass("even")
      rows.each (index) ->
        if index % 2 is 1
          $(this).addClass("even")

    sortify_tables: () ->
      tables = $('#admin-tablesorter')
      tables.tablesorter()

    clickify_table_datas: () ->
      $('.service_request_links').live("click", () ->
        $('.admin_indicator').css('display', 'inline-block')
        sr_id = $(this).data('sr_id')
        ssr_id = $(this).attr('data-ssr_id')
        url = "/portal/admin/sub_service_requests/#{ssr_id}"

        document.location.href = url
      )

    clickify_cwf_table_datas: () ->
      $('.service_request_links_cwf').live("click", () ->
        $('.admin_indicator').css('display', 'inline-block')
        sr_id = $(this).data('sr_id')
        ssr_id = $(this).attr('data-ssr_id')
        url = "/clinical_work_fulfillment/sub_service_requests/#{ssr_id}"

        document.location.href = url
      )
  }
