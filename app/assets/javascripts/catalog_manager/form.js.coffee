# Copyright © 2011-2018 MUSC Foundation for Research Development
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

$ ->

  ##############################################
  ###                Multi-Use               ###
  ##############################################

  $(document).on 'click', '.multi_toggle label', ->
    $(this).addClass('active')
    $(this).children('input').prop('checked')
    $(this).siblings('.active').removeClass('active')

  ##############################################
  ###         Organization General Info      ###
  ##############################################

  $(document).on 'click', '#display-in-sparc .toggle', ->
    if $(this).find("[id*='_is_available']").prop('checked')
      $('#enable-all-services').removeClass('hidden')
    else
      $('#enable-all-services').addClass('hidden')

  ##############################################
  ###         Organization User Rights       ###
  ##############################################

  $(document).on 'change', '.super-user-checkbox', ->
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    checked = $(this).prop('checked')

    $.ajax
      type: if $(this).prop('checked') then 'POST' else 'DELETE'
      url: "/catalog_manager/super_user?super_user[identity_id]=#{identity_id}&super_user[organization_id]=#{organization_id}"

      success: ->
        $("#su-access-empty-protocols-#{identity_id}").prop('disabled', !checked)
        if !checked
          $("#su-access-empty-protocols-#{identity_id}").prop('checked', false)

  $(document).on 'change', '.catalog-manager-checkbox', ->
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    checked = $(this).prop('checked')

    $.ajax
      type: if checked then 'POST' else 'DELETE'
      url: "/catalog_manager/catalog_manager?catalog_manager[identity_id]=#{identity_id}&catalog_manager[organization_id]=#{organization_id}"

      success: ->
        $("#cm-edit-historic-data-#{identity_id}").prop('disabled', !checked)
        if !checked
          $("#cm-edit-historic-data-#{identity_id}").prop('checked', false)

  $(document).on 'change', '.service-provider-checkbox', ->
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    checked = $(this).prop('checked')

    $.ajax
      type: if checked then 'POST' else 'DELETE'
      url: "/catalog_manager/service_provider?service_provider[identity_id]=#{identity_id}&service_provider[organization_id]=#{organization_id}"

  $(document).on 'change', '.su-access-empty-protocols', ->
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    access_empty_protocols = $(this).prop('checked')

    $.ajax
      type: 'PUT'
      url: "/catalog_manager/super_user?super_user[identity_id]=#{identity_id}&super_user[organization_id]=#{organization_id}&super_user[access_empty_protocols]=#{access_empty_protocols}"

  $(document).on 'change', '.cm-edit-historic-data', ->
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    edit_historic_data = $(this).prop('checked')

    $.ajax
      type: 'PUT'
      url: "/catalog_manager/catalog_manager?catalog_manager[identity_id]=#{identity_id}&catalog_manager[organization_id]=#{organization_id}&catalog_manager[edit_historic_data]=#{edit_historic_data}"

  $(document).on 'change', '.sp-is-primary-contact', ->
    togglePrimaryContactChecks()

    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    is_primary_contact = $(this).prop('checked')

    $.ajax
      type: 'PUT'
      url: "/catalog_manager/service_provider?service_provider[identity_id]=#{identity_id}&service_provider[organization_id]=#{organization_id}&service_provider[is_primary_contact]=#{is_primary_contact}"

  $(document).on 'change', '.sp-hold-emails', ->
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    hold_emails = $(this).prop('checked')

    $.ajax
      type: 'PUT'
      url: "/catalog_manager/service_provider?service_provider[identity_id]=#{identity_id}&service_provider[organization_id]=#{organization_id}&service_provider[hold_emails]=#{hold_emails}"

  $(document).on 'click', '.remove-user-rights', (event) ->
    event.preventDefault()
    if confirm (I18n['catalog_manager']['organization_form']['user_rights']['remove_confirm'])
      identity_id = $(this).data('identity-id')
      organization_id = $(this).data('organization-id')
      $.ajax
        type: 'POST'
        url: "/catalog_manager/organizations/remove_user_rights_row"
        data:
          user_rights:
            identity_id: identity_id
            organization_id: organization_id


  $(document).on 'click', '.cancel-user-rights', (event) ->
    event.preventDefault()
    $(this).closest('.row').fadeOut(1000, () -> $(this).remove())

  ##############################################
  ###     Organization Associated Surveys    ###
  ##############################################

  $(document).on 'click', 'button.remove-associated-survey', (event) ->
    survey_id = $(this).data('survey-id')
    surveyable_id = $(this).data('id')
    if confirm(I18n['catalog_manager']['organization_form']['surveys']['survey_delete'])
      $.ajax
        type: 'POST'
        url: "/catalog_manager/organizations/remove_associated_survey"
        data:
          associated_survey_id: survey_id
          surveyable_id: surveyable_id

  $(document).on 'click', 'button.add-associated-survey', (event) ->
    if $('#new_associated_survey').val() == ''
      alert "No survey selected"
    else
      survey_id = $(this).closest('.row').find('.new_associated_survey')[0].value
      surveyable_type = $(this).data('type')
      surveyable_id = $(this).data('id')
      $.ajax
        type: 'POST'
        url: "/catalog_manager/organizations/add_associated_survey"
        data:
          survey_id: survey_id
          surveyable_type : surveyable_type
          surveyable_id : surveyable_id

  ##############################################
  ###         Organization Fulfillment       ###
  ##############################################

  $(document).on 'change', '.clinical-provider-checkbox', ->
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    $.ajax
      type: if $(this).prop('checked') then 'POST' else 'DELETE'
      url: "/catalog_manager/clinical_provider?clinical_provider[identity_id]=#{identity_id}&clinical_provider[organization_id]=#{organization_id}"

  $(document).on 'change', '.patient-registrar-checkbox', ->
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    $.ajax
      type: if $(this).prop('checked') then 'POST' else 'DELETE'
      url: "/catalog_manager/patient_registrar?patient_registrar[identity_id]=#{identity_id}&patient_registrar[organization_id]=#{organization_id}"


  $(document).on 'click', '.remove-fulfillment-rights', (event) ->
    event.preventDefault()
    if confirm (I18n['catalog_manager']['organization_form']['user_rights']['remove_confirm'])
      identity_id = $(this).data('identity-id')
      organization_id = $(this).data('organization-id')
      $.ajax
        type: 'POST'
        url: "/catalog_manager/organizations/remove_fulfillment_rights_row?fulfillment_rights[identity_id]=#{identity_id}&fulfillment_rights[organization_id]=#{organization_id}"


  $(document).on 'click', '.cancel-fulfillment-rights', (event) ->
    event.preventDefault()
    $(this).closest('.row').fadeOut(1000, () -> $(this).remove())

  ##############################################
  ###          Organization Statuses         ###
  ##############################################

  $(document).on 'click', '#use_default_statuses .toggle', ->
    checked = $(this).find("#use_default_statuses").prop('checked')
    org_id = $(this).find("#use_default_statuses").data('organization-id')
    $("#status-options .panel-body").fadeOut(1000)
    $.ajax
      type: 'POST'
      url: "/catalog_manager/organizations/toggle_default_statuses"
      data:
        checked: checked
        organization_id: org_id

  $(document).on 'change', '.available-status-checkbox', ->
    $.ajax
      type: "POST"
      url: '/catalog_manager/organizations/update_status_row'
      data:
        status_key: $(this).data('status-key')
        organization_id: $(this).data('organization-id')
        selected: $(this).prop('checked')
        status_type: "AvailableStatus"

  $(document).on 'change', '.editable-status-checkbox', ->
    $.ajax
      type: "POST"
      url: '/catalog_manager/organizations/update_status_row'
      data:
        status_key: $(this).data('status-key')
        organization_id: $(this).data('organization-id')
        selected: $(this).prop('checked')
        status_type: "EditableStatus"


  ##############################################
  ###          Organization Pricing          ###
  ##############################################

  $(document).on 'click', '.edit_pricing_setup_link', ->
    pricing_setup_id = $(this).data('pricing-setup-id')
    $.ajax
      type: "GET"
      url: "/catalog_manager/pricing_setups/#{pricing_setup_id}/edit"

  $(document).on 'click', '#new_pricing_setup_link', ->
    org_id = $(this).data('organization-id')
    $.ajax
      type: "GET"
      url: "/catalog_manager/pricing_setups/new"
      data:
        organization_id: org_id

  $(document).on 'submit', '#pricing_setup_modal form', ->
    $('#pricing_setup_submit').attr('disabled','disabled')

  $(document).on 'click', '#apply_federal_percent', ->
    federal_value = $('.federal_rate_field').val()
    $('.linked_to_federal').val(federal_value)


  $(document).on 'click', '#increase_decrease_button', ->
    org_id = $(this).data('organization-id')
    $.ajax
      type: "GET"
      url: "/catalog_manager/organizations/increase_decrease_modal"
      data:
        organization_id: org_id


  $(document).on 'submit', '#increase_decrease_modal form', ->
    $('#increase_decrease_submit').attr('disabled','disabled')

  $(document).on 'click', '#edit_subsidy_map_button', ->
    subsidy_map_id = $(this).data('subsidy-map-id')
    $.ajax
      type: "GET"
      url: "/catalog_manager/subsidy_maps/#{subsidy_map_id}/edit"

  $(document).on 'submit', '#subsidy_map_modal form', ->
    $('#subsidy_map_submit').attr('disabled','disabled')


  ##############################################
  ###           Submission Emails            ###
  ##############################################

  $(document).on 'click', 'button.remove-submission-email', (event) ->
    id = $(this).data('submission-id')
    if confirm (I18n['catalog_manager']['organization_form']['submission_emails']['remove_confirm'])
      $.ajax
        type: 'DELETE'
        url: "/catalog_manager/submission_emails/#{id}"

  $(document).on 'click', 'button.add-submission-email', (event) ->
    new_submission_email = $('#new_submission_email').val()
    org_id = $(this).data('organization-id')
    $.ajax
      type: 'POST'
      url: "/catalog_manager/submission_emails"
      data:
        submission_email:
          email: new_submission_email
          organization_id: org_id

  ##############################################
  ###          Service General Info          ###
  ##############################################
  $(document).on 'change', '#service_program', ->
    service_id = $(this).data('service-id')
    program_id = $(this).find('option:selected').val()

    $.ajax
      type: 'GET'
      dataType: 'script'
      url: "/catalog_manager/services/#{service_id}/reload_core_dropdown"
      data:
        program_id: program_id

  ##############################################
  ###          Service Components            ###
  ##############################################

  $(document).on 'click', 'button.remove-service-component', (event) ->
    component = $(this).data('component')
    service_id = $(this).data('service-id')
    if confirm (I18n['catalog_manager']['service_form']['remove_component_confirm'])
      $.ajax
        type: 'POST'
        url: "/catalog_manager/services/#{service_id}/change_components"
        data:
          service:
            component: component

  $(document).on 'click', 'button.add-service-component', (event) ->
    component = $('input#new_component').val()
    service_id = $(this).data('service-id')
    $.ajax
      type: 'POST'
      url: "/catalog_manager/services/#{service_id}/change_components"
      data:
        service:
          component: component


  ##############################################
  ###          Related Services              ###
  ##############################################

  $(document).on 'click', 'button.remove-related-services', (event) ->
    service_relation_id = $(this).data('service-relation-id')
    if confirm (I18n['catalog_manager']['related_services_form']['remove_related_service_confirm'])
      $.ajax
        type: 'POST'
        url: "/catalog_manager/services/remove_related_service"
        data:
          service_relation_id: service_relation_id

  $(document).on 'change', '.required', (event) ->
    service_relation_id = $(this).data('service-relation-id')
    required = $(this).prop('checked')
    $.ajax
      type: 'POST'
      url: "/catalog_manager/services/update_related_service"
      data:
        service_relation_id: service_relation_id
        service_relation:
          required: required

  $(document).on 'change', '.linked_quantity', (event) ->
    service_relation_id = $(this).data('service-relation-id')
    linked_quantity = $(this).prop('checked')

    ajax_call = ->
      $.ajax
        type: 'POST'
        url: "/catalog_manager/services/update_related_service"
        data:
          service_relation_id: service_relation_id
          service_relation:
            linked_quantity: linked_quantity

    if !linked_quantity
      $(this).siblings('.linked_quantity_container').fadeOut(750, ->
        ajax_call()
        )
    else
      ajax_call()

  $(document).on 'change', '.linked_quantity_total', (event) ->
    service_relation_id = $(this).data('service-relation-id')
    linked_quantity_total = $(this).val()
    $.ajax
      type: 'POST'
      url: "/catalog_manager/services/update_related_service"
      data:
        service_relation_id: service_relation_id
        service_relation:
          linked_quantity_total: linked_quantity_total

  ##############################################
  ###             Service Pricing            ###
  ##############################################

  $(document).on 'click', '.edit_pricing_map_link', ->
    pricing_map_id = $(this).data('pricing-map-id')
    $.ajax
      type: "GET"
      url: "/catalog_manager/pricing_maps/#{pricing_map_id}/edit"

  $(document).on 'click', '#new_pricing_map_link', ->
    service_id = $(this).data('service-id')
    $.ajax
      type: "GET"
      url: "/catalog_manager/pricing_maps/new"
      data:
        service_id: service_id

  $(document).on 'change', '#pricing_map_full_rate', ->
    full_rate = $(this).val()
    service_id = $(this).data('service-id')
    pricing_map_id = $(this).data('pricing-map-id')
    display_date = $('#pricing_map_display_date').val()
    $.ajax
      type: "GET"
      url: "/catalog_manager/pricing_maps/refresh_rates"
      data:
        id: pricing_map_id
        pricing_map:
          full_rate: full_rate
          display_date: display_date
          service_id: service_id

  $(document).on 'submit', '#pricing_map_modal form', ->
    $('#pricing_map_modal .modal-footer .btn-primary').attr('disabled','disabled')

  $(document).on 'change', '#pricing_map_quantity_type', ->
    new_value = $(this).val()
    $('.input-group-addon').text(new_value)

  $(document).on 'change', '#pricing_map_unit_type', ->
    new_value = $(this).val()
    $('.input-group-addon').text(new_value)

  $(document).on 'change', 'input.override_field', ->
    alert(I18n['catalog_manager']['service_form']['pricing_map_form']['change_override_alert'])

(exports ? this).togglePrimaryContactChecks = () ->
  if $('.sp-is-primary-contact:checked').length >= 3
    $('.sp-is-primary-contact:not(:checked)').prop('disabled', 'disabled')
  else
    $('.sp-is-primary-contact:not(:checked)').prop('disabled', '')