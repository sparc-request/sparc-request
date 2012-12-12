# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  Sparc.services = {
    ready: ->
      Sparc.services.create_accordion()
      Sparc.services.create_date_display()
      Sparc.config.displayDatesForUser($('.datepicker, .disabled_datepicker'))

    create_accordion: (selector=".pricing_map_accordion") ->
      $(selector).accordion("destroy")
      $(selector).accordion({
        clearStyle: true,
        collapsible: true,
        active: false
      })
    
    create_date_display: (changed_element, selector, str) ->
      date = Date.parse($(changed_element).val())
      arr = $(selector)
      same_date = false
      date_warning = false  
      for index in arr
        old_date = Date.parse($(index).val())
        if date == old_date && index != changed_element
          same_date = true
        else if date < old_date && index != changed_element
          date_warning = true

      if same_date == false
        div = $(changed_element).closest('div')
        display_date = Sparc.config.readyMyDate(div.find('.submitted_date:first').val())
        effective_date = Sparc.config.readyMyDate(div.find('.submitted_date:last').val())
        div.prevAll('h3:first').find('a').html("Effective On #{effective_date} - Display On #{display_date}")    
      else if same_date == true
        alert "You can't have two #{str} dates on the same day!"
        $(changed_element).val('')
        $(changed_element).siblings().val('')
        date_warning = false
      if date_warning == true
        if (confirm "You have selected a #{str} date before an existing #{str} date, are you sure you want to do this?") == false
          $(changed_element).val('')
          $(changed_element).siblings().val('')          
        else if (confirm "Are you sure?") == false
          $(changed_element).val('')
          $(changed_element).siblings().val('')
  }

  $('.add_pricing_map').live('click', ->
    blank_pricing_map = $('.blank_pricing_map').html()
    $('.pricing_map_accordion').append(blank_pricing_map)
    Sparc.services.create_accordion()
    Sparc.config.setDatePicker()
  )

  $('.remove_pricing_map').live('click', ->
    div = $(this).closest('div')
    div.prevAll('h3:first').remove()
    div.remove()
  )

  $('.add_pricing_setup').live('click', ->
    blank_pricing_setup = $('.blank_pricing_setup').html()
    pricing_map_form = $('.pricing_setup_accordion').append(blank_pricing_setup)
    pricing_map_form.find('.effective_date').addClass('validate')
    pricing_map_form.find('.display_date').addClass('validate')
    pricing_map_form.find('.rate').addClass('validate')
    pricing_map_form.find('.pricing_setup_form:last').append('<input name="pricing_setups[blank_pricing_setup][newly_created]" type="hidden" value="true">')
    Sparc.services.create_accordion('.pricing_setup_accordion')
    Sparc.config.setDatePicker()
    $('.blank_field_errors').css('display', 'inline-block')
    $('.save_button').attr('disabled', true)
  )

  $('.effective_date_hidden, .pricing_map_effective_date_hidden').live('change', ->
    Sparc.services.create_date_display(this, $(this).attr('date_type'), 'Effective')
  )
  
  $('.display_date_hidden, .pricing_map_display_date_hidden').live('change', ->
    Sparc.services.create_date_display(this, $(this).attr('date_type'), 'Display')
  )
  
  $(".rate_field").live('change', ->
    unless $(this).hasClass('service_rate')
      old_value = $(this).attr('old_value')
      rate_type = $(this).attr('rate_type')
      unless confirm("Changing this value will override the pre-calculated #{rate_type} Rate for this service.")
        $(this).attr('old_value', old_value)
        $(this).val(old_value)
  )
  
  $('.service_rate').live('change', ->
    rate = $(this).val()
    organization_id = $(this).attr('organization_id')
    display_date = $(this).closest('div').find(".pricing_map_display_date_hidden").val()
    data = {full_rate: rate, organization_id: organization_id, date: display_date}
    service_rate = $(this)
    $.ajax({
      url: "services/get_updated_rate_maps"
      data: data
      success: (data) ->
        service_rate.closest('tr').siblings('.federal_rate_row').find('.set_rate').html("#{data.federal_rate}")
        service_rate.closest('tr').siblings('.corporate_rate_row').find('.set_rate').html("#{data.corporate_rate}")
        service_rate.closest('tr').siblings('.other_rate_row').find('.set_rate').html("#{data.other_rate}")
        service_rate.closest('tr').siblings('.member_rate_row').find('.set_rate').html("#{data.member_rate}")
    })
  )
  
