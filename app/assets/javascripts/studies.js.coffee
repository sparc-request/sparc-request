$(document).ready ->
  display_dependencies=
    "#study_funding_status" :
      pending_funding    : ['.pending_funding']
      funded             : ['.funded']
    "#study_potential_funding_source" :
      internal           : ['.internal_potential_funded_pilot_project']
    "#study_funding_source" :
      federal            : ['.federal']
      internal           : ['.internal_funded_pilot_project']
    '#study_research_types_info_attributes_human_subjects' :
      'true'             : ['.hr_number', '.pro_number', '.irb_of_record', '.submission_type',
                            '.irb_approval_date', '.irb_expiration_date', '.approval_pending',
                            '.study_phase']
    '#study_research_types_info_attributes_vertebrate_animals' :
      'true'             : ['.iacuc_number', '.name_of_iacuc', '.iacuc_approval_date',
                            '.iacuc_expiration_date']
    '#study_research_types_info_attributes_investigational_products' :
      'true'             : ['.ind_number', '.ide_number']
    '#study_research_types_info_attributes_ip_patents':
      'true'             : ['.patent_number', '.inventors']
    '#study_investigational_products_info_attributes_ind_number':
      'true'             : ['.ind_on_hold']
    '#study_impact_areas_attributes_6__destroy':
      'true'             : ['.impact_other']

  FormFxManager.registerListeners($('.edit-project-view'), display_dependencies)

  $('#study_funding_status').change ->
    $('#study_funding_source').val("")
    $('#study_potential_funding_source').val("")
    $('#study_funding_source').change()
    $('#study_potential_funding_source').change()
    $('#study_indirect_cost_rate').val("")

  $('#study_research_types_info_attributes_investigational_products').change ->
    if !$(this).is(':checked')
      $('#study_investigational_products_info_attributes_ind_number').val('')
      $('#study_investigational_products_info_attributes_ind_number').change()
      $('#study_investigational_products_info_attributes_ind_on_hold').attr('checked', false)

  $('#study_federal_phs_sponsor').change ->
    $('#study_federal_non_phs_sponsor').val("")

  $('#study_federal_non_phs_sponsor').change ->
    $('#study_federal_phs_sponsor').val("")

  $('#study_funding_source, #study_potential_funding_source').change ->
    switch $(this).val()
      when "internal", "college" then $('#study_indirect_cost_rate').val("0")
      when "industry", "foundation", "investigator" then $('#study_indirect_cost_rate').val("25")
      when "federal" then $('#study_indirect_cost_rate').val("49")

  $("#funding_start_date").datepicker(
    changeMonth: true,
    changeYear:true,
    constrainInput: true,
    dateFormat: "m/dd/yy",
    showButtonPanel: true,
    altField: '#study_funding_start_date',
    altFormat: 'yy-mm-dd',

    beforeShow: (input)->
      callback = ->
        buttonPane = $(input).datepicker("widget").find(".ui-datepicker-buttonpane")
        buttonPane.find('button.ui-datepicker-current').hide()
        $("<button>", {
          class: "ui-state-default ui-priority-primary ui-corner-all"
          text: "Clear"
          click: ->
            $.datepicker._clearDate(input)
        }).appendTo(buttonPane)
      setTimeout( callback, 1)
    ).addClass('date');

  $('#funding_start_date').attr("readOnly", true)

  $("#potential_funding_start_date").datepicker(
    changeMonth: true,
    changeYear:true,
    constrainInput: true,
    dateFormat: "m/dd/yy",
    showButtonPanel: true,
    altField: '#study_potential_funding_start_date',
    altFormat: 'yy-mm-dd',

    beforeShow: (input)->
      callback = ->
        buttonPane = $(input).datepicker("widget").find(".ui-datepicker-buttonpane")
        buttonPane.find('button.ui-datepicker-current').hide()
        $("<button>", {
          class: "ui-state-default ui-priority-primary ui-corner-all"
          text: "Clear"
          click: ->
            $.datepicker._clearDate(input)
        }).appendTo(buttonPane)
      setTimeout( callback, 1)
    ).addClass('date');

  $('#potential_funding_start_date').attr("readOnly", true)

  $("#irb_approval_date").datepicker(
    changeMonth: true,
    changeYear:true,
    constrainInput: true,
    dateFormat: "m/dd/yy",
    showButtonPanel: true,
    altField: '#study_human_subjects_info_attributes_irb_approval_date',
    altFormat: 'yy-mm-dd',

    beforeShow: (input)->
      callback = ->
        buttonPane = $(input).datepicker("widget").find(".ui-datepicker-buttonpane")
        buttonPane.find('button.ui-datepicker-current').hide()
        $("<button>", {
          class: "ui-state-default ui-priority-primary ui-corner-all"
          text: "Clear"
          click: ->
            $.datepicker._clearDate(input)
        }).appendTo(buttonPane)
      setTimeout( callback, 1)
    ).addClass('date');

  $('#irb_approval_date').attr("readOnly", true)

  $("#irb_expiration_date").datepicker(
    changeMonth: true,
    changeYear:true,
    constrainInput: true,
    dateFormat: "m/dd/yy",
    showButtonPanel: true,
    altField: '#study_human_subjects_info_attributes_irb_expiration_date',
    altFormat: 'yy-mm-dd',

    beforeShow: (input)->
      callback = ->
        buttonPane = $(input).datepicker("widget").find(".ui-datepicker-buttonpane")
        buttonPane.find('button.ui-datepicker-current').hide()
        $("<button>", {
          class: "ui-state-default ui-priority-primary ui-corner-all"
          text: "Clear"
          click: ->
            $.datepicker._clearDate(input)
        }).appendTo(buttonPane)
      setTimeout( callback, 1)
    ).addClass('date');

  $('#irb_expiration_date').attr("readOnly", true)

  $("#iacuc_approval_date").datepicker(
    changeMonth: true,
    changeYear:true,
    constrainInput: true,
    dateFormat: "m/dd/yy",
    showButtonPanel: true,
    altField: '#study_vertebrate_animals_info_attributes_iacuc_approval_date',
    altFormat: 'yy-mm-dd',

    beforeShow: (input)->
      callback = ->
        buttonPane = $(input).datepicker("widget").find(".ui-datepicker-buttonpane")
        buttonPane.find('button.ui-datepicker-current').hide()
        $("<button>", {
          class: "ui-state-default ui-priority-primary ui-corner-all"
          text: "Clear"
          click: ->
            $.datepicker._clearDate(input)
        }).appendTo(buttonPane)
      setTimeout( callback, 1)
    ).addClass('date');

  $('#iacuc_approval_date').attr("readOnly", true)

  $("#iacuc_expiration_date").datepicker(
    changeMonth: true,
    changeYear:true,
    constrainInput: true,
    dateFormat: "m/dd/yy",
    showButtonPanel: true,
    altField: '#study_vertebrate_animals_info_attributes_iacuc_expiration_date',
    altFormat: 'yy-mm-dd',

    beforeShow: (input)->
      callback = ->
        buttonPane = $(input).datepicker("widget").find(".ui-datepicker-buttonpane")
        buttonPane.find('button.ui-datepicker-current').hide()
        $("<button>", {
          class: "ui-state-default ui-priority-primary ui-corner-all"
          text: "Clear"
          click: ->
            $.datepicker._clearDate(input)
        }).appendTo(buttonPane)
      setTimeout( callback, 1)
    ).addClass('date');

  $('#iacuc_expiration_date').attr("readOnly", true)

#This is to disabled the submit after you click once, so you can't fire multiple posts at once.
$("form").submit ->
   $('input[type=image]').attr('disabled', 'disabled')
