#= require cart
#= require navigation

$ ->

  $(".jquery-ui-date").datepicker(
    changeMonth: true,
    changeYear:true,
    constrainInput: true,
    dateFormat: "m/dd/yy",
    showButtonPanel: true,

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

  $('.jquery-ui-date').attr("readOnly", true)