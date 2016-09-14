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

$ ->
  Sparc.catalog = {

    clear_error_fields: ->
      $('.errorExplanation').html('').hide()

    handle_ajax_errors: (errors_array, entity_type) ->
      errors_array = JSON.parse(errors_array)
      error_string = ""
      error_number = 0
      for key,value of errors_array
        for error in value
          humanized_error_message = Sparc.catalog.humanize_error_message(key, error)
          error_number += 1
          error_string += humanized_error_message
      $('.errorExplanation').html("<h2>#{error_number} error(s) prevented this #{entity_type} from being saved:</h2>
        <p>There were problems with the following fields:</p>
        <ul>
          #{error_string}
        </ul>
      ").show()
      $("html, body").animate({ scrollTop: 0 }, "slow")

    humanize_error_message: (key, error) ->
      new_key = key.replace(/.\./g, '_')
      humanized_message = I18n["pricing_setup"]["#{new_key}"]
      returned_message = ""

      if humanized_message != undefined
        returned_message = "<li>#{humanized_message} #{error}</li>"
      else
        returned_message = "<li>#{key[0].toUpperCase()}#{key.substr(1, key.length - 1)} #{error}</li>"

      return returned_message

    submitRateChanges: (entity_id, percentage, effective_date, display_date) ->
      data = { entity_id: entity_id, percentage: percentage, effective_date: Sparc.config.readyMyDate(effective_date, 'send'), display_date: Sparc.config.readyMyDate(display_date, 'send')}
      $.ajax({
        url: "/catalog_manager/update_pricing_maps"
        data: data
        success: ->
        error: ->
      })

    validate_change_rate_date: (changed_element, entity_id, str) ->
      date = $(changed_element).val()
      data = {date: date, entity_id: entity_id, str: str}
      date_element = $(changed_element)
      $.ajax({
        url: "/catalog_manager/validate_pricing_map_dates"
        data: data
        success: (data) ->
          if data.same_dates == 'true'
            if str == 'display_date'
              alert I18n["catalog_manager_js"]["same_display_date"]
            else
              alert I18n["catalog_manager_js"]["same_effective_date"]
            date_element.val('')
            date_element.siblings().val('')
          if data.later_dates == 'true'
            if str == 'display_date'
              proceed = confirm I18n["catalog_manager_js"]["later_display_date"]
            else
              proceed = confirm I18n["catalog_manager_js"]["later_effective_date"]
            if proceed == false
              date_element.val('')
              date_element.siblings().val('')
            else if (confirm I18n["js_confirm"]) == false
              date_element.val('')
              date_element.siblings().val('')
      })
  }

  $('#processing_request').dialog({ dialogClass: 'processing_request', resizable: false, height: 100, autoOpen: false })

  $('.custom_button').button()

  # alert until all services have a pricing setup either at the program or provider level
  $(".provider_program_core_save").live 'click', ->
    verify_valid_pricing_setups()

  verify_valid_pricing_setups = () ->
    $.get '/catalog_manager/verify_valid_pricing_setups', (data) ->
      if data == 'true'
        $(".pricing_setup_error").hide()
      else
        $(".pricing_setup_error p").html(data)
        $(".pricing_setup_error").show()

  verify_valid_pricing_setups()

  $('.associated_survey_delete').live 'click', ->
    if confirm I18n["catalog_manager_js"]["survey_delete"]
      $.post '/catalog_manager/catalog/remove_associated_survey', {associated_survey_id: $(this).data('associated_survey_id')}, (data) ->
        $('#associated_survey_info').html(data)

  $('.add_associated_survey').live 'click', ->
    if $('#new_associated_survey').val() == ''
      alert "No survey selected"
    else
      $.post '/catalog_manager/catalog/add_associated_survey', {survey_id: $('#new_associated_survey').val(), surveyable_type: $(this).data('surveyable_type'), surveyable_id: $(this).data('surveyable_id')}, (data) ->
        $('#associated_survey_info').html(data)
    return false

  $('#program').live 'change', ->
    new_program_id = $(this).val()
    $.post '/catalog_manager/services/update_cores/' + new_program_id, (data) ->
      $('#core_list').html(data)

  $('#catalog').jstree
      core:
        initially_open: 'root'
      "search" : {"show_only_matches" : true}
      plugins: ['html_data', 'search', 'ui', 'crrm', 'themeroller']
      themeroller:
        item: null
  .bind 'loaded.jstree', () ->
    $.each( $('a'), (i, x) ->
      remove_class = false
      if $(x).hasClass('disabled_node')
        $.each( $(x).parent('li').find('a'), (j, y) ->
          unless $(y).hasClass('disabled_node')
            remove_class = true
        )
        $(x).removeClass('disabled_node').addClass('viewable_node') if remove_class == true
    )
    $('.disabled_node').css("color", "lightgray")
    $('.viewable_node').css("color", "#FF6F60")

  .bind 'select_node.jstree', (node, node_ref) ->
    $('.increase_decrease_dialog:first').dialog().dialog('destroy').remove() # calling dialog() to make sure it exists before we destroy, otherwise jquery ui complains if you click too fast
    click_text = node_ref.rslt.obj.context.textContent || node_ref.rslt.obj.context.innerText
    if click_text
      click_text = $.trim(click_text)

      # create an institution
      if /^Create New Institution$/.test click_text
        institution_name = prompt(I18n["catalog_manager_js"]["institution_prompt"])
        if institution_name and institution_name.length > 0
          $.post '/catalog_manager/institutions', {name: institution_name}

      # create a provider
      if /^Create New Provider$/.test click_text
        institution_id = node_ref.rslt.obj.parents('li:eq(0)').children('a').attr('cid')
        provider_name = prompt(I18n["catalog_manager_js"]["provider_prompt"])
        if provider_name and provider_name.length > 0
          $.post '/catalog_manager/providers', {name: provider_name, institution_id: institution_id}

      # create a program
      if /^Create New Program$/.test click_text
        provider_id = node_ref.rslt.obj.parents('li:eq(0)').children('a').attr('cid')
        program_name = prompt(I18n["catalog_manager_js"]["program_prompt"])
        if program_name and program_name.length > 0
          $.post '/catalog_manager/programs', {name: program_name, provider_id: provider_id}

      # create a core
      if /^Create New Core$/.test click_text
        program_id = node_ref.rslt.obj.parents('li:eq(0)').children('a').attr('cid')
        core_name = prompt(I18n["catalog_manager_js"]["core_prompt"])
        if core_name and core_name.length > 0
          $.post '/catalog_manager/cores', {name: core_name, program_id: program_id}

      # create a service
      if /^Create New Service$/.test click_text
        parent_id = node_ref.rslt.obj.parents('li:eq(0)').children('a').attr('cid')
        parent_object_type = node_ref.rslt.obj.parents('li:eq(0)').children('a').attr('object_type')

        $.get "/catalog_manager/services/verify_parent_service_provider", {parent_id: parent_id, parent_object_type: parent_object_type}, (data)->
          alert_text = data

          if alert_text.length < 1
            $.get("/catalog_manager/services/new", {parent_id: parent_id, parent_object_type: parent_object_type}, (data)->
              $('#details').html(data) )
          else
            alert(alert_text)


    return unless node_ref.rslt.obj.context.attributes['object_type']

    $('#processing_request').dialog('open')
    cid = node_ref.rslt.obj.context.attributes['cid'].nodeValue
    obj_type = node_ref.rslt.obj.context.attributes['object_type'].nodeValue

    $(this).jstree('toggle_node')
    $('#details').load "/catalog_manager/#{obj_type}s/#{cid}", ->
      $('#processing_request').dialog('close')
  $('#search_button').click ->
    $('#catalog').jstree 'search', $('#search').val()
    if $('#catalog li:visible').size() == 0
      $('#no_results').show()
    else
      $('#no_results').hide()

  $('#clear_search').click ->
    $('#catalog').jstree 'clear_search'
    $('#catalog').jstree 'close_all'
    $('#no_results').hide()
    $('#search_box input#search').val('')

  # related services
  $('input#new_rs').live 'focus', -> $(this).val('')
  $('input#new_rs').live 'keydown.autocomplete', ->
    $(this).autocomplete
      source: "/catalog_manager/services/search",
      minLength: 3,
      select: (event, ui) ->
        $.post '/catalog_manager/services/associate', {related_service: ui.item.id, service: $('#service_id').val()}, (data) ->
          $('#rs_info').html(data)


  $('.rs_delete').live 'click', ->
    if confirm I18n["catalog_manager_js"]["service_remove"]
      $.post '/catalog_manager/services/disassociate', {service_relation_id: $(this).data('service_relation_id')}, (data) ->
        $('#rs_info').html(data)

  $('.optional').live 'click', ->
    $.post '/catalog_manager/services/set_optional', {service_relation_id: $(this).attr('id'), optional: $(this).val()}, (data) ->
        $('#rs_info').html(data)

  $('.linked_quantity').live 'click', ->
    $.post '/catalog_manager/services/set_linked_quantity', {service_relation_id: $(this).data('service_relation_id'), linked_quantity: $(this).val()}, (data) ->
        $('#rs_info').html(data)

  $('.linked_quantity_total').live 'change', ->
    $.post '/catalog_manager/services/set_linked_quantity_total', {service_relation_id: $(this).data('service_relation_id'), linked_quantity_total: $(this).val()}, (data) ->
        $('#rs_info').html(data)


  ############################
  # Begin pricing map logic
  ############################q

  $('.one_time_fee').live 'click', ->
    pricing_map_ids = String($(this).data('pricing_map_ids'))
    pricing_map_ids = pricing_map_ids.split(' ')
    index = 0
    while index < pricing_map_ids.length
      if $(this).is(":checked")
        enable_per_patient_save()
        show_otf_attributes(pricing_map_ids[index])
        if ($("#otf_quantity_type_#{pricing_map_ids[index]}").val() == "") || ($("#otf_unit_type_#{pricing_map_ids[index]}").val() == "") || ($("#otf_quantity_minimum_#{pricing_map_ids[index]}").val() == "") || ($("#otf_unit_max_#{pricing_map_ids[index]}").val() == "")
          disable_otf_service_save()
      else
        hide_otf_attributes(pricing_map_ids[index])
        enable_otf_service_save()
        if ($("#clinical_quantity_#{pricing_map_ids[index]}").val() == "") || ($("#unit_factor_#{pricing_map_ids[index]}").val() == "") || ($("#unit_minimum_#{pricing_map_ids[index]}").val() == "")
          disable_per_patient_save()
      index++


  $('.otf_quantity_type').live 'change', ->
    pricing_map_id = $(this).data('pricing_map_id')
    if pricing_map_id == undefined
      pricing_map_id = ""
    if $("#otf_unit_type_#{pricing_map_id}").val() == "N/A"
      $("#otf_attributes_#{pricing_map_id}").html('# ' + $(this).val())
    else
      $("#otf_attributes_#{pricing_map_id}").html('# ' + $(this).val() + ' / ' + '# ' + $("#otf_unit_type_#{pricing_map_id}").val())

  $('.otf_unit_type').live 'change', ->
    pricing_map_id = $(this).data('pricing_map_id')
    if pricing_map_id == undefined
      pricing_map_id = ""
    if $(this).val() == "N/A"
      $("#otf_attributes_#{pricing_map_id}").html('# ' + $("#otf_quantity_type_#{pricing_map_id}").val())
    else
      $("#otf_attributes_#{pricing_map_id}").html('# ' + $("#otf_quantity_type_#{pricing_map_id}").val() + ' / ' + '# ' + $(this).val())

  # Pricing map one time fee validations
  $('.otf_quantity_type, .otf_quantity_minimum, .otf_unit_type, .otf_unit_max').live('change', ->
    blank_field = false
    for field in $('.otf_validate')
      blank_field = true if (($(field).val() == "") && $(field).is(":visible"))

    if blank_field == false
      enable_otf_service_save()
    else
      disable_otf_service_save()
  )

  # Pricing map per patient validations
  # These need to be separate due to conditions presented by the checkbox
  # for one time fees.
  $('.service_unit_type, .service_unit_factor, .service_unit_minimum').live('change', ->
    blank_field = false
    for field in $('.per_patient_validate')
      blank_field = true if (($(field).val() == "") && $(field).is(":visible"))

    if blank_field == false
      enable_per_patient_save()
    else
      disable_per_patient_save()
  )

  # pricing map methods
  show_otf_attributes = (pricing_map_id) ->
    $("#otf_fields_#{pricing_map_id}").show()
    $("#pp_fields_#{pricing_map_id}").hide()

  hide_otf_attributes = (pricing_map_id) ->
    $("#otf_fields_#{pricing_map_id}").hide()
    $("#pp_fields_#{pricing_map_id}").show()

  disable_otf_service_save = () ->
    $('.save_button').attr('disabled', true)
    $('.otf_field_errors').css('display', 'inline-block')

  enable_otf_service_save = () ->
    $('.save_button').removeAttr('disabled')
    $('.otf_field_errors').hide()

  disable_per_patient_save = () ->
    $('.save_button').attr('disabled', true)
    $('.per_patient_errors').css('display', 'inline-block')

  enable_per_patient_save = () ->
    $('.save_button').removeAttr('disabled')
    $('.per_patient_errors').hide()

  #######################
  # End pricing map logic
  #######################

  # submission e-mails
  $('input#new_se').live 'focus', -> $(this).val('')
  $('input#new_se').live 'keypress', (e) ->
    if e.which == 13
      return false if $(this).val() == ''
      new_tr = $('.ses table.se_clone_table tbody tr:first').clone()
      new_name = new_tr.find('.se_value').attr('name').replace('CLONE', '')
      new_tr.find('.se_value').attr('name', new_name)
      new_tr.find('.se_value').val($(this).val())
      new_tr.find('.se_display').html($(this).val())
      new_tr.appendTo($('.ses table.se_table tbody'))
      $('table.se_table').show()
      e.preventDefault()
      $('#entity_form').submit()
      $(this).val('')

  $('.se_delete').live 'click', ->
    if $(this).attr('id')
      $.post '/catalog_manager/catalog/remove_submission_email', {submission_email: $(this).attr('id'), org_unit: $('#org_unit_id').val()}, (data) ->
        $('#se_info').html(data)
    else
      $(this).parent().parent().remove()

  # super users
  $('input#new_su').live 'focus', -> $(this).val('')
  $('input#new_su').live 'keydown.autocomplete', ->
    $(this).autocomplete
      source: "/catalog_manager/identities/search",
      minLength: 3,
      select: (event, ui) ->
        $.post '/catalog_manager/identities/associate_with_org_unit', {identity: ui.item.value, org_unit: $('#org_unit_id').val(), rel_type: "super_user_organizational_unit"}, (data) ->
          $('#su_info').html(data)

  $('.su_delete').live 'click', ->
    if confirm I18n["catalog_manager_js"]["super_user_remove"]
      $.post '/catalog_manager/identities/disassociate_with_org_unit', {relationship: $(this).attr('id'), org_unit: $('#org_unit_id').val(), rel_type: "super_user_organizational_unit"}, (data) ->
        $('#su_info').html(data)

  # clinical providers
  $('input#new_cp').live 'focus', -> $(this).val('')
  $('input#new_cp').live 'keydown.autocomplete', ->
    $(this).autocomplete
      source: "/catalog_manager/identities/search",
      minLength: 3,
      select: (event, ui) ->
        $.post '/catalog_manager/identities/associate_with_org_unit', {identity: ui.item.value, org_unit: $('#org_unit_id').val(), rel_type: "clinical_provider_organizational_unit"}, (data) ->
          $('#cp_info').html(data)

  $('.cp_delete').live 'click', ->
    if confirm I18n["catalog_manager_js"]["clinical_provider_remove"]
      $.post '/catalog_manager/identities/disassociate_with_org_unit', {relationship: $(this).attr('id'), org_unit: $('#org_unit_id').val(), rel_type: "clinical_provider_organizational_unit"}, (data) ->
        $('#cp_info').html(data)

  # service providers
  $('input#new_sp').live 'focus', -> $(this).val('')
  $('input#new_sp').live 'keydown.autocomplete', ->
    $(this).autocomplete
      source: "/catalog_manager/identities/search",
      minLength: 3,
      select: (event, ui) ->
        $.post '/catalog_manager/identities/associate_with_org_unit', {identity: ui.item.value, org_unit: $('#org_unit_id').val(), rel_type: "service_provider_organizational_unit"}, (data) ->
          $('#sp_info').html(data)

  $('.sp_delete').live 'click', ->
    if confirm I18n["catalog_manager_js"]["service_provider_remove"]
      $.post '/catalog_manager/identities/disassociate_with_org_unit', {relationship: $(this).attr('id'), org_unit: $('#org_unit_id').val(), rel_type: "service_provider_organizational_unit"}, (data) ->
        $('#sp_info').html(data)

  #catalog managers
  $('input#new_cm').live 'focus', -> $(this).val('')
  $('input#new_cm').live 'keydown.autocomplete', ->
    $(this).autocomplete
      source: "/catalog_manager/identities/search",
      minLength: 3,
      select: (event, ui) ->
        $.post '/catalog_manager/identities/associate_with_org_unit', {identity: ui.item.value, org_unit: $('#org_unit_id').val(), rel_type: "catalog_manager_organizational_unit"}, (data) ->
          $('#cm_info').html(data)

  $('.cm_delete').live 'click', ->
    if confirm I18n["catalog_manager_js"]["cm_rights_remove"]
      $.post '/catalog_manager/identities/disassociate_with_org_unit', {relationship: $(this).attr('id'), org_unit: $('#org_unit_id').val(), rel_type: "catalog_manager_organizational_unit"}, (data) ->
        $('#cm_info').html(data)

  #primary contact toggle
  $('.primary_contact').live 'click', ->
    $.post '/catalog_manager/identities/set_primary_contact', {service_provider: $(this).attr('identity'), org_id: $(this).attr('org_id')}, (data) ->
        $('#sp_info').html(data)

  #hold emails toggle
  $('.hold_emails').live 'click', ->
    $.post '/catalog_manager/identities/set_hold_emails', {service_provider: $(this).attr('identity'), org_id: $(this).attr('org_id')}, (data) ->
        $('#sp_info').html(data)

  #edit history data toggle
  $('.edit_historic_data').live 'click', ->
    current_user_id = $(this).attr('current_user_id')
    identity = $(this).attr('identity')
    identity_user_id = $(this).attr('identity_user_id')
    $.post '/catalog_manager/identities/set_edit_historic_data', {manager: $(this).attr('identity'), org_id: $(this).attr('org_id')}, (data) ->
      $('#cm_info').html(data)
      if current_user_id == identity_user_id
        alert(I18n["catalog_manager_js"]["permission_change"])
        window.location = ''

  $('.increase_decrease_rates').live('click', ->
    $('.increase_decrease_dialog').dialog('open')
    $('.increase_or_decrease').val($(this).attr('action'))
  )

  $('.submit_rate_change').live('click', ->
    percent_of_change = $(this).siblings('.percent_of_change').val()
    effective_date = $(this).siblings('.effective_date').val()
    display_date = $(this).siglings('.display_date').val()
    entity_id = $(this).siblings('.entity_id').val()
    Sparc.catalog.submitRateChanges(entity_id, percent_of_change, effective_date, display_date)
  )

  # Service and general (not specific to per patient or one time fees) pricing map validations
  $('.service_name,
    .service_order,
    .service_rate,
    .pricing_map_display_date,
    .pricing_map_effective_date').live('change', ->
    blank_field = false
    validates = $(this).closest('.service_form').find('.validate')

    for field in $(validates)
      blank_field = true if $(field).val() == ""

    if blank_field == false
      $('.save_button').removeAttr('disabled')
      $('.blank_field_errors').hide()
    else
      $('.save_button').attr('disabled', true)
      $('.blank_field_errors').css('display', 'inline-block')
  )

  $('.remove_pricing_setup').live('click', ->
    $(this).parent().prevAll('h3:first').remove()
    $(this).parent().remove()
  )

  $('.change_rate_display_date, .change_rate_effective_date').live('change', ->
    entity_id = $(this).closest('.increase_decrease_dialog').children('.entity_id').val()
    Sparc.catalog.validate_change_rate_date(this, entity_id, $(this).attr('display')) if $(this).val() != ""
  )

  $('.display_date, .effective_date').live('change', ->
    entity_id = $(this).siblings(".submitted_date").attr('entity_id')
    Sparc.catalog.validate_change_rate_date(this, entity_id, $(this).attr('display')) if $(this).val() != ""
  )

  $('a.add_new_excluded_funding_source').live 'click', ->
    funding_source = $('select.new_excluded_funding_source').val()
    org_type = $(this).attr('org_type')
    org_id = $(this).attr('org_id')
    data = {funding_source: funding_source, org_id: org_id, org_type: org_type}
    $.ajax
      url: '/catalog_manager/catalog/add_excluded_funding_source'
      type: 'post'
      data: data


  $('span.remove_funding_source').live 'click', ->
    remove_this = $(this).parent()
    if confirm(I18n["js_confirm"])
      $.ajax
        url: '/catalog_manager/catalog/remove_excluded_funding_source'
        type: 'delete'
        data: { funding_source_id: $(this).attr('funding_source_id') }
        success: ->
          remove_this.remove()

  $(document).on 'click', 'fieldset.parent:not(.active)', ->
    $('fieldset.parent.active').removeClass('active').children('fieldset').hide('blind')
    $(this).children('fieldset').show('blind')
    $(this).addClass('active')

  $(document).on('change', 'input#service_one_time_fee', ->
    $('#components_wrapper').toggle()
  )

  $(document).on('change', 'input[id*="_tag_list_epic"]', ->
    $('#epic_wrapper').toggle()
    $("#epic_wrapper input[type='checkbox']").attr('checked', false)
  )

  $(document).on('change', 'input[id*="_tag_list_clinical_work_fulfillment"]', ->
    $('#cwf_wrapper').toggle()
    $('#cwf_wrapper input.cwf_clear').val('')
    $("#cwf_wrapper input[type='checkbox']").attr('checked', false)
  )

  $(document).on('click','.unavailable_button', ->
    $('#processing_request').dialog('open')
    show_unavailable = $(this).data('show-unavailable')
    window.location.assign("/catalog_manager?show_unavailable=#{show_unavailable}")
  )



