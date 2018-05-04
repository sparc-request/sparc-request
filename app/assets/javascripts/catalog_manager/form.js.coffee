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
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    $.ajax
      type: if $(this).prop('checked') then 'POST' else 'DELETE'
      url: "/catalog_manager/super_user?super_user[identity_id]=#{identity_id}
                                       &super_user[organization_id]=#{organization_id}"

  $(document).on 'change', '.catalog-manager-checkbox', ->
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    checked = $(this).prop('checked')
    $.ajax
      type: if checked then 'POST' else 'DELETE'
      url: "/catalog_manager/catalog_manager?catalog_manager[identity_id]=#{identity_id}
                                            &catalog_manager[organization_id]=#{organization_id}"
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
      url: "/catalog_manager/service_provider?service_provider[identity_id]=#{identity_id}
                                             &service_provider[organization_id]=#{organization_id}"
      success: ->
        $("#sp-is-primary-contact-#{identity_id}").prop('disabled', !checked)
        $("#sp-hold-emails-#{identity_id}").prop('disabled', !checked)
        if !checked
          $("#sp-is-primary-contact-#{identity_id}").prop('checked', false)
          $("#sp-hold-emails-#{identity_id}").prop('checked', false)

  $(document).on 'change', '.clinical-provider-checkbox', ->
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    $.ajax
      type: if $(this).prop('checked') then 'POST' else 'DELETE'
      url: "/catalog_manager/clinical_provider?clinical_provider[identity_id]=#{identity_id}
                                             &clinical_provider[organization_id]=#{organization_id}"

  $(document).on 'change', '.cm-edit-historic-data', ->
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    edit_historic_data = $(this).prop('checked')
    $.ajax
      type: 'PUT'
      url: "/catalog_manager/catalog_manager?catalog_manager[identity_id]=#{identity_id}
                                            &catalog_manager[organization_id]=#{organization_id}
                                            &catalog_manager[edit_historic_data]=#{edit_historic_data}"

  $(document).on 'change', '.sp-is-primary-contact', ->
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    is_primary_contact = $(this).prop('checked')
    $.ajax
      type: 'PUT'
      url: "/catalog_manager/service_provider?service_provider[identity_id]=#{identity_id}
                                             &service_provider[organization_id]=#{organization_id}
                                             &service_provider[is_primary_contact]=#{is_primary_contact}"

  $(document).on 'change', '.sp-hold-emails', ->
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    hold_emails = $(this).prop('checked')
    $.ajax
      type: 'PUT'
      url: "/catalog_manager/service_provider?service_provider[identity_id]=#{identity_id}
                                             &service_provider[organization_id]=#{organization_id}
                                             &service_provider[hold_emails]=#{hold_emails}"

  $(document).on 'click', '.remove-user-rights', (event) ->
    event.preventDefault()
    identity_id = $(this).data('identity-id')
    organization_id = $(this).data('organization-id')
    $.ajax
      type: 'DELETE'
      url: "/catalog_manager/user_right?user_rights[identity_id]=#{identity_id}
                                       &user_rights[organization_id]=#{organization_id}"
      # data:
      #   user_rights:
      #     identity_id: identity_id
      #     organization_id: $(this).data('organization-id')
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




