# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  add_error = (selector, message) ->
    $(selector).parent().append("<br class='custom_error_message' /><span class='custom_error_message ui-corner-all'>#{message}</span>")
    $(selector).addClass("custom_error_field")

  remove_error = (selector) ->
    $(selector).parent().find('.custom_error_message').remove()
    $(selector).removeClass("custom_error_field")
  
  remove_all_errors = ->
    $('.custom_error_message').remove()
    $('.custom_error_field').removeClass('custom_error_field')
    
  cannot_contain_letters = (selector) ->
    $(selector).val().match(/^[0-9]\d*(\.\d+)?$/) || [null]
  
  validate_numbers_only = (selector) ->
    unless $(selector).val() == ''
      validated_number = cannot_contain_letters(selector) 
      unless validated_number[0]
        add_error(selector, "#{$(selector).attr('display')} can only contain numbers.")
        $(selector).val('')

  validate_percentages_to_federal_percentage = (selector, federal) ->
    unless $(selector).val() == ''  
      validated_number = cannot_contain_letters(selector)
      if parseFloat(validated_number[0]) < parseFloat(federal)
        add_error(selector, "#{$(selector).attr('display')} percentage must be >= to the Federal percentage.")
        $(selector).val('')        

    
  $('.percentage_field').live('change', ->
    remove_error(this)
    unless $(this).hasClass('federal_percentage_field')
      federal_number = $(this).closest('tr').siblings('.federal_row').find('.federal_percentage_field').val()
    validate_percentages_to_federal_percentage(this, federal_number)
    validate_numbers_only(this)
  )
  
  $('.federal_percentage_field').live('change', ->
    remove_error(this)
    field = $(this).closest('fieldset').find('.percentage_field')
    for percentage in $(field)
      validate_percentages_to_federal_percentage(percentage, $(this).val())       
      validate_numbers_only(percentage)
  )
  
  $('.unit_field, .rate_field').live('change', ->
    remove_error(this)
    validate_numbers_only(this)
  )
  
  $('.apply_federal_to_all_link').live('click', ->
    federal_value = $(this).closest('tr').siblings('.federal_row').find('.federal_percentage_field').val()
    $(this).closest('tr').siblings('.corporate_row').find('.corporate_percentage_field').val(federal_value).change()
    $(this).closest('tr').siblings('.other_row').find('.other_percentage_field').val(federal_value).change()
    $(this).closest('tr').siblings('.member_row').find('.member_percentage_field').val(federal_value).change()
    remove_all_errors()
  )
    
  $('.save_button').live('click', ->
    setTimeout( callback, 50)
    $('.spinner').show()
  )

  callback = ->
    $('.save_button').attr('disabled', 'disabled')
    
  $('.service_rate').live('blur', ->
    $(this).formatCurrency()
  )
  
  $('#fix_pricing_maps_dialog').dialog({
    title: "Fix Pricing Maps"
    closeText: ""
    autoOpen: false
    modal: true
    width: 575
    height: 200
  })
  
  $('.fix_pricing_maps_button').live('click', ->
    if $(this).attr("class").search("disabled_button") == -1
      $('.pricing_map_fix_spinner').show()
      button_text = $(this)
      button_text.addClass("disabled_button")
      entity_id = $('.fix_pricing_maps_entity_id').val()
      old_value = $('.fix_pricing_maps_old_value').val()
      old_value_type = $('.fix_pricing_maps_old_value_type').val()
      new_value = $('.fix_pricing_maps_new_value').val()
      data = {entity_id: entity_id, old_value: old_value, old_value_type: old_value_type, new_value: new_value}
      $.ajax({
        url: "catalog_manager/update_dates_on_pricing_maps"
        data: data
        success: (data) ->
          $('.pricing_map_fix_spinner').hide()
          button_text.removeClass("disabled_button")
          $('#fix_pricing_maps_dialog').dialog('close')
      })
  )

  $('.dont_fix_pricing_maps_button').live('click', ->
    $('#fix_pricing_maps_dialog').dialog('close')
  )
  
  $('.fix_pricing_maps_on_change').live('change', ->
    entity_name = $(this).attr('entity_name')
    $('.fix_pricing_maps_entity_id').val($(this).attr('entity_id'))
    $('.fix_pricing_maps_entity_type').val($(this).attr('entity_type'))
    $('.fix_pricing_maps_old_value').val($(this).attr('old_value'))
    $('.fix_pricing_maps_new_value').val($(this).val())

    $(this).attr('old_value', $(this).val())
    
    $('.fix_pricing_maps_old_value_type').val("effective_date") if $(this).attr('class').search("effective_date_hidden") > -1
    $('.fix_pricing_maps_old_value_type').val("display_date") if $(this).attr('class').search("display_date_hidden") > -1
    $('.fix_pricing_maps_dialog_content').html("The pricing maps under this entity (#{entity_name}) should be readjusted to use the date you just selected.")
    $('#fix_pricing_maps_dialog').dialog("open")
  )
