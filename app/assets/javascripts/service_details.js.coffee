#= require cart
#= require navigation

$ ->
  # handle removing an arm and clicking save & continue - set subjects and visits to 1 
  #TODO this isn't the best way to do this, maybe we should default subjects and visits to 1
  $(document).on 'nested:fieldRemoved', (event) ->
    field = event.field
    field.find('.skinny_fields input').val('1')

  # show/hide remove arm link depending on how many arms exist,  hide when on one arm remains
  nested_field_count = $('form .fields:visible').length
  $remove_link = $('a.remove_nested_fields')

  toggleRemoveLink = ->
    $('a.remove_nested_fields').toggle(nested_field_count > 1)

  $(document).on 'nested:fieldAdded', ->
    nested_field_count += 1
    toggleRemoveLink()

  $(document).on 'nested:fieldRemoved', ->
    nested_field_count -= 1
    toggleRemoveLink()

  toggleRemoveLink()

  # end code to show/hide remove arm link

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
    ).addClass('date')
  
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
    ).addClass('date')

  $('#start_date').attr("readOnly", true)
  $('#end_date').attr("readOnly", true)

  # Validations for existing arms

  $(document).on('change', '.arm_subject_count', ->
    if $(this).data('unlocked') == false
      new_count = $(this).val()
      old_count = $(this).data('subject_count')
      if new_count < old_count
        alert("You can not reduce the subject count of a previously defined arm.")
        $(this).val(old_count)
  )

  $(document).on('change', '.arm_visit_count', ->
    if $(this).data('unlocked') == false
      new_count = $(this).val()
      old_count = $(this).data('visit_count')
      if new_count < old_count
        alert("You can not reduce the visit count of a previously defined arm.")
        $(this).val(old_count)
  )

  $('#navigation_form').submit ->
    go = true
    $('.line_item_quantity').each ->
      if verify_unit_minimum($(this)) == false
        go = false
    return go

$('.units_per_quantity').live 'change', ->
  max = parseInt($(this).attr('data-qty_max'), 10)
  user_input = parseInt($(this).val(), 10)
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
  unit_min = parseInt(obj.attr('unit_minimum'), 10)
  prev_qty = obj.attr('current_quantity')
  qty = parseInt(obj.val(), 10)
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
