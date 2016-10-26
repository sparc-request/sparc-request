# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
      if $(selector).hasClass('ui-accordion')
        $(selector).accordion("destroy")
      $(selector).accordion({
        heightStyle: 'content',
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
        if str == "display"
          alert I18n["services_js"]["same_display_date"]
        else
          alert I18n["services_js"]["same_effective_date"]
        $(changed_element).val('')
        $(changed_element).siblings().val('')
        date_warning = false
      if date_warning == true
        if str == "display"
          proceed = confirm I18n["services_js"]["before_display_date"]
        else
          proceed = confirm I18n["services_js"]["before_effective_date"]
        if proceed == false
          $(changed_element).val('')
          $(changed_element).siblings().val('')
        else if (confirm I18n["js_confirm"]) == false
          $(changed_element).val('')
          $(changed_element).siblings().val('')
  }

  add_service_level_component_input = (position) ->
    html      = "<tr id='service_component_position_#{position}'><td><input class='service_component_field' position='#{position}' type='text'></td></tr>"
    table     = $('fieldset.service_level_components table tbody')
    table.append html

  update_components_field = () ->
    hidden_field = $("input[name='service[components]']")
    inputs = $('fieldset.service_level_components input[type="text"]')
    components_string = ""
    inputs.each ->
      input = $(@)
      if input.val().length > 0
        components_string += input.val() + ","
    hidden_field.val(components_string)

  $(document).on 'click', 'fieldset.service_level_components button.add', ->
    input_count   = $('fieldset.service_level_components').find('input[type="text"]').length
    new_input_ids = [input_count, input_count += 1, input_count += 1]

    add_service_level_component_input new_input_id for new_input_id in new_input_ids

  $(document).on 'change', '.service_component_field', ->
    update_components_field()

  $(document).on 'click', 'fieldset.service_level_components button.delete', ->
    position = $(this).attr('position')
    $("#service_component_position_#{position}").remove()
    update_components_field()

  $('.add_pricing_map').live('click', ->
    blank_pricing_map = $('.blank_pricing_map').html()
    $('.pricing_map_accordion').append(blank_pricing_map)
    Sparc.services.create_accordion()
    Sparc.config.setDatePicker()
    $('.blank_field_errors').css('display', 'inline-block')
    $('.per_patient_errors').css('display', 'inline-block')
    $('.save_button').attr('disabled', true)
    if $('.one_time_fee').is(":checked")
      $('.otf_field_errors').show()
      $(".per_patient_errors").hide()
  )

  $('.remove_pricing_map').live('click', ->
    div = $(this).closest('div')
    div.prevAll('h3:first').remove()
    div.remove()
    $('.save_button').removeAttr('disabled')
    $('.blank_field_errors').hide()
    $('.per_patient_errors').hide()
    $('.otf_field_errors').hide()
  )

  $('.add_pricing_setup').live('click', ->
    blank_pricing_setup = $('.blank_pricing_setup').html()
    pricing_setup_form = $('.pricing_setup_accordion').append(blank_pricing_setup)
    pricing_setup_form.find('.effective_date').addClass('validate')
    pricing_setup_form.find('.display_date').addClass('validate')
    pricing_setup_form.find('.rate').addClass('validate')
    pricing_setup_form.find('.percentage_field').addClass('validate')
    pricing_setup_form.find('.pricing_setup_form:last').append('<input name="pricing_setups[blank_pricing_setup][newly_created]" type="hidden" value="true">')
    Sparc.services.create_accordion('.pricing_setup_accordion')
    Sparc.config.setDatePicker()
  )

  $('.pricing_map_effective_date_hidden').live('change', ->
    Sparc.services.create_date_display(this, $(this).attr('date_type'), 'effective')
  )

  $('.pricing_map_display_date_hidden').live('change', ->
    Sparc.services.create_date_display(this, $(this).attr('date_type'), 'display')
  )

  # $(document).on('input')

  $(".rate_field").live('change', ->
    unless $(this).hasClass('service_rate')
      old_value = $(this).attr('old_value')
      rate_type = $(this).attr('rate_type')
      unless confirm(I18n["services_js"]["rate_field_confirm"])
        $(this).attr('old_value', old_value)
        $(this).val(old_value)
  )

  $('.service_rate').live('change', ->
    rate = $(this).val(parseFloat($(this).val()).toFixed(2)).val()
    organization_id = $(this).attr('organization_id')
    display_date = $(this).closest('div').find(".pricing_map_display_date_hidden").val()
    data = {full_rate: rate, organization_id: organization_id, date: display_date}
    service_rate = $(this)
    $.ajax({
      url: "catalog_manager/services/get_updated_rate_maps"
      data: data
      success: (data) ->
        service_rate.closest('tr').siblings('.federal_rate_row').find('.set_rate').html("#{data.federal_rate}")
        service_rate.closest('tr').siblings('.corporate_rate_row').find('.set_rate').html("#{data.corporate_rate}")
        service_rate.closest('tr').siblings('.other_rate_row').find('.set_rate').html("#{data.other_rate}")
        service_rate.closest('tr').siblings('.member_rate_row').find('.set_rate').html("#{data.member_rate}")
    })
  )

