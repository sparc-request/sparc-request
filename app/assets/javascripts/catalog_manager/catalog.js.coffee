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
          error_number += 1
          error_string += "<li>#{key[0].toUpperCase()}#{key.substr(1, key.length - 1)} #{error}</li>"

      $('.errorExplanation').html("<h2>#{error_number} error(s) prevented this #{entity_type} from being saved:</h2>
        <p>There were problems with the following fields:</p>
        <ul>
          #{error_string}
        </ul>
      ").show()

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
            alert "A pricing map already exists with that #{(str.replace('_',' '))}.  Please choose another date."
            date_element.val('')
            date_element.siblings().val('')
          if data.later_dates == 'true'
            if (confirm "This #{(str.replace('_',' '))} is before the #{(str.replace('_',' '))} of existing pricing maps, are you sure you want to do this?") == false
              date_element.val('')
              date_element.siblings().val('')
            else if (confirm "Are you sure?") == false
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
    if confirm 'Are you sure you want to remove this Associated Survey?'
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

      # create an institution
      if /Create New Institution/.test click_text
        institution_name = prompt("Please enter the name of the institution to be created")
        if institution_name and institution_name.length > 0
          $.post '/catalog_manager/institutions', {name: institution_name}

      # create a provider
      if /Create New Provider/.test click_text
        institution_id = node_ref.rslt.obj.parents('li:eq(0)').children('a').attr('cid')
        provider_name = prompt("Please enter the name of the provider you would like to create")
        if provider_name and provider_name.length > 0
          $.post '/catalog_manager/providers', {name: provider_name, institution_id: institution_id}

      # create a program
      if /Create New Program/.test click_text
        provider_id = node_ref.rslt.obj.parents('li:eq(0)').children('a').attr('cid')
        program_name = prompt("Please enter the name of the program you would like to create")
        if program_name and program_name.length > 0
          $.post '/catalog_manager/programs', {name: program_name, provider_id: provider_id}

      # create a core
      if /Create New Core/.test click_text
        program_id = node_ref.rslt.obj.parents('li:eq(0)').children('a').attr('cid')
        core_name = prompt("Please enter the name of the core you would like to create")
        if core_name and core_name.length > 0
          $.post '/catalog_manager/cores', {name: core_name, program_id: program_id}

      # create a service
      if /Create New Service/.test click_text
        parent_id = node_ref.rslt.obj.parents('li:eq(0)').children('a').attr('cid')
        parent_object_type = node_ref.rslt.obj.parents('li:eq(0)').children('a').attr('object_type')
        $.get("/catalog_manager/services/new", {parent_id: parent_id, parent_object_type: parent_object_type},
              (data)-> $('#details').html(data) )

    return unless node_ref.rslt.obj.context.attributes['object_type']
    
    $('#processing_request').dialog('open')

    cid = node_ref.rslt.obj.context.attributes['cid'].nodeValue
    obj_type = node_ref.rslt.obj.context.attributes['object_type'].nodeValue

    $(this).jstree('toggle_node')
    $('#details').load "/catalog_manager/#{obj_type}s/#{cid}", ->
      $('#processing_request').dialog('close')

  $('#search_button').click ->
    $('#catalog').jstree 'search', $('#search').val()

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
    if confirm 'Are you sure you want to remove this Related Service?'
      $.post '/catalog_manager/services/disassociate', {service_relation_id: $(this).data('service_relation_id')}, (data) ->
        $('#rs_info').html(data)
  
  $('.optional').live 'click', ->
    $.post '/catalog_manager/services/set_optional', {service_relation_id: $(this).attr('id'), optional: $(this).val()}, (data) ->
        $('#rs_info').html(data)

  # clinical work fulfillment
  $('.cwf input[type=checkbox]').live 'click', ->
    if $(this).is(":checked")
      $('.cwf.position_field').show()
    else
      $('.cwf.position_field').hide()
      
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
    if confirm 'Are you sure you want to remove this Super User?'
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
    if confirm 'Are you sure you want to remove this Clinical Provider?'
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
    if confirm 'Are you sure you want to remove this Service Provider?'
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
    if confirm 'Are you sure you want to remove rights for this user from the Catalog Manager?'
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
        alert("You are changing your own permissions. Your page will refresh automatically when this window closes.")
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

  $('.display_date, .effective_date, .rate, .percentage_field').live('change', ->
    validate_dates_and_rates()
  )

  $('.service_name,
    .service_order,
    .service_rate,
    .service_unit_type,
    .service_unit_factor,
    .service_unit_minimum,
    .service_units_per_qty_max,
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
    validate_dates_and_rates()
  )

  validate_dates_and_rates = () ->
    blank_field = false

    for field in $('.validate')
      blank_field = true if $(field).val() == ""

    if blank_field == false
      $('.save_button').removeAttr('disabled')
      $('.blank_field_errors').hide()
    else
      $('.save_button').attr('disabled', true)
      $('.blank_field_errors').css('display', 'inline-block')



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
    if confirm("Are you sure?")
      $.ajax
        url: '/catalog_manager/catalog/remove_excluded_funding_source'
        type: 'delete'
        data: { funding_source_id: $(this).attr('funding_source_id') }
        success: ->
          remove_this.remove()

