#= require cart
#= require navigation

$ ->

  $("#start_date").datepicker(
    changeMonth: true,
    changeYear:true,
    constrainInput: true,
    dateFormat: "m/dd/yy",
    showButtonPanel: true,
    altField: '#service_request_start_date',
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
  
  $("#end_date").datepicker(
    changeMonth: true,
    changeYear:true,
    constrainInput: true,
    dateFormat: "m/dd/yy",
    showButtonPanel: true,
    altField: '#service_request_end_date',
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

  $('#start_date').attr("readOnly", true)
  $('#end_date').attr("readOnly", true)
