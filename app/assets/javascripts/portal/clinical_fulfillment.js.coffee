$(document).ready ->

  $(document).on('change', '.clinical_select_data', ->
    $('#visit_form .spinner_wrapper').show()
    visit_name = $('option:selected', this).attr('data-appointment_id')
    setTimeout((->
      $('#visit_form .study_tracker_table').hide()
      $("table[data-appointment_table=#{visit_name}]").css("display", "table")
      $('#visit_form .spinner_wrapper').hide()
    ), 250)
  )

  $(document).on('click', '.clinical_tab_data', ->
    clicked = $(this)
    $('#visit_form .spinner_wrapper').show()
    core_name = $(this).attr('id')
    setTimeout((->
      $('.cwf_tabs li.ui-state-active').removeClass('ui-state-active')
      clicked.parent('li').addClass('ui-state-active')
      $('#visit_form .study_tracker_table tbody tr.fields').hide()
      if clicked.attr('data-has_access') == "false"
        $("." + core_name).find('input').prop('disabled', true)
      $("." + core_name).css("display", "table-row")
      $('#visit_form .spinner_wrapper').hide()
    ), 250)
  )

