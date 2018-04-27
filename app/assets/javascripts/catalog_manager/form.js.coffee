# Copyright © 2011-2017 MUSC Foundation for Research Development
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

##############################################
###          Org General Info              ###
##############################################
$ ->
  $(document).on 'click', '#enable-all-services label', ->
    $(this).addClass('active')
    $(this).children('input').prop('checked')
    $(this).siblings('.active').removeClass('active')

  $(document).on 'click', '#display-in-sparc .toggle', ->
    if $(this).find("[id*='_is_available']").prop('checked')
      $('#enable-all-services').removeClass('hidden')
    else
      $('#enable-all-services').addClass('hidden')

  $(document).on 'click', '#close-general-info', ->
    $('#general-info-collapse').collapse('hide')

  ##############################################
  ###          Org User Rights               ###
  ##############################################

  $(document).on 'change', '.super-user-checkbox', ->
    $.ajax
      type: if $(this).prop('checked') then 'POST' else 'DELETE'
      url: '/catalog_manager/super_user'
      data:
        super_user:
          identity_id: $(this).data('identity-id')
          organization_id: $(this).data('organization-id')

  $(document).on 'change', '.catalog-manager-checkbox', ->
    identity_id = $(this).data('identity-id')
    checked = $(this).prop('checked')
    $.ajax
      type: if checked then 'POST' else 'DELETE'
      url: '/catalog_manager/catalog_manager'
      data:
        catalog_manager:
          identity_id: identity_id
          organization_id: $(this).data('organization-id')
      success: ->
        $("#cm-edit-historic-data-#{identity_id}").prop('disabled', !checked)
        if !checked
          $("#cm-edit-historic-data-#{identity_id}").prop('checked', false)

  $(document).on 'change', '.service-provider-checkbox', ->
    identity_id = $(this).data('identity-id')
    checked = $(this).prop('checked')
    $.ajax
      type: if checked then 'POST' else 'DELETE'
      url: '/catalog_manager/service_provider'
      data:
        service_provider:
          identity_id: identity_id
          organization_id: $(this).data('organization-id')
      success: ->
        $("#sp-is-primary-contact-#{identity_id}").prop('disabled', !checked)
        $("#sp-hold-emails-#{identity_id}").prop('disabled', !checked)
        if !checked
          $("#sp-is-primary-contact-#{identity_id}").prop('checked', false)
          $("#sp-hold-emails-#{identity_id}").prop('checked', false)

  $(document).on 'change', '.clinical-provider-checkbox', ->
    $.ajax
      type: if $(this).prop('checked') then 'POST' else 'DELETE'
      url: '/catalog_manager/clinical_provider'
      data:
        clinical_provider:
          identity_id: $(this).data('identity-id')
          organization_id: $(this).data('organization-id')

  $(document).on 'change', '.cm-edit-historic-data', ->
    $.ajax
      type: 'PUT'
      url: 'catalog_manager/catalog_manager/'
      data:
        catalog_manager:
          identity_id: $(this).data('identity-id')
          organization_id: $(this).data('organization-id')
          edit_historic_data: $(this).prop('checked')

  $(document).on 'change', '.sp-is-primary-contact', ->
    $.ajax
      type: 'PUT'
      url: 'catalog_manager/service_provider/'
      data:
        service_provider:
          identity_id: $(this).data('identity-id')
          organization_id: $(this).data('organization-id')
          is_primary_contact: $(this).prop('checked')

  $(document).on 'change', '.sp-hold-emails', ->
    $.ajax
      type: 'PUT'
      url: 'catalog_manager/service_provider/'
      data:
        service_provider:
          identity_id: $(this).data('identity-id')
          organization_id: $(this).data('organization-id')
          hold_emails: $(this).prop('checked')

  $(document).on 'click', '.remove-user-rights', (event) ->
    event.preventDefault()
    identity_id = $(this).data('identity-id')
    $.ajax
      type: 'DELETE'
      url: 'catalog_manager/user_right'
      data:
        user_rights:
          identity_id: identity_id
          organization_id: $(this).data('organization-id')
      success: ->
        $("#user-rights-row-#{identity_id}").fadeOut(1000, () -> $(this).remove())

  ##############################################
  ###          Service Components            ###
  ##############################################

  $(document).on 'click', 'button.remove-service-component', (event) ->
    component = $(this).closest('.form-group.row').find('input.component_string')[0].value
    service_id = $(this).data('service')
    if confirm (I18n['catalog_manager']['service_form']['remove_component_confirm'])
      $.ajax
        type: 'POST'
        url: "catalog_manager/services/change_components"
        data: 
          component: component
          service_id: service_id

  $(document).on 'click', 'button.add-service-component', (event) ->
    component = $(this).closest('.form-group.row').find('input.component_string')[0].value
    service_id = $(this).data('service')
    $.ajax
      type: 'POST'
      url: "catalog_manager/services/change_components"
      data: 
        component: component
        service_id: service_id

  ##############################################
  ###          Related Services              ###
  ##############################################

  $('input#new_related_service').live 'focus', -> $(this).val('')
  $('input#new_related_service').live 'keydown.autocomplete', ->
    service_id = $(this).data('service')
    $(this).autocomplete
      source: "/catalog_manager/services/search",
      minLength: 3,
      select: (event, ui) ->
        $.ajax
          type: 'POST'
          url: "catalog_manager/services/change_related_services"
          data:
            service: service_id

  $(document).on 'click', 'button.remove-related-services', (event) ->
    component = $(this).closest('.form-group.row').find('input.component_string')[0].value
    service_id = $(this).data('service')
    if confirm (I18n['catalog_manager']['service_form']['remove_component_confirm'])
      $.ajax
        type: 'POST'
        url: "catalog_manager/services/change_related_services"
        data: 
          component: component
          service_id: service_id

  $(document).on 'click', 'button.add-related-services', (event) ->
    component = $(this).closest('.form-group.row').find('input.component_string')[0].value
    service_id = $(this).data('service')
    $.ajax
      type: 'POST'
      url: "catalog_manager/services/change_related_services"
      data: 
        component: component
        service_id: service_id



