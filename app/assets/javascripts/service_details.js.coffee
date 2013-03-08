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

  $('#navigation_form').submit ->
    go = true
    $('.line_item_quantity').each ->
      if verify_unit_minimum($(this)) == false
        go = false
    return go

$('.units_per_quantity').live 'change', ->
  max = $(this).attr('data-qty_max')
  user_input = $(this).val()
  if user_input > max
    $(this).css({'border': '2px solid red'})
    $('#unit_max_error').css({'border': '2px solid red'})
    $('#unit_quantity').html(user_input)
    $('#unit_max').html(max + ".")
    $('#unit_max_error').show()
    $(this).val(max)
  else
    $('#unit_max_error').hide()
    $('#unit_max_error').css('border', '')
    $(this).css('border', '')

verify_unit_minimum = (obj) ->
  unit_min = obj.attr('unit_minimum')
  prev_qty = obj.attr('current_quantity')
  qty = obj.val()
  if qty < unit_min
    obj.val(prev_qty)
    obj.css({'border': '2px solid red'})
    $('#quantity').html(qty)
    $('#unit_minimum').html(unit_min + ".")
    $('#one_time_fee_errors').show()
    return false
  else
    $('#one_time_fee_errors').hide()
    obj.css('border', '')
