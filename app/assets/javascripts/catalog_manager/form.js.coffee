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
    if $(this).prop('checked')
      $.ajax
        type: 'POST'
        url: '/catalog_manager/super_user'
        data:
          super_user:
            identity_id: $(this).data('identity-id')
            organization_id: $(this).data('organization-id')
    else
      $.ajax
        type: 'DELETE'
        url: "/catalog_manager/super_user/"
        data:
          super_user:
            identity_id: $(this).data('identity-id')
            organization_id: $(this).data('organization-id')

  $(document).on 'change', '.catalog-manager-checkbox', ->
    if $(this).prop('checked')
      $.ajax
        type: 'POST'
        url: '/catalog_manager/catalog_manager'
        data:
          catalog_manager:
            identity_id: $(this).data('identity-id')
            organization_id: $(this).data('organization-id')
    else
      $.ajax
        type: 'DELETE'
        url: "/catalog_manager/catalog_manager/"
        data:
          catalog_manager:
            identity_id: $(this).data('identity-id')
            organization_id: $(this).data('organization-id')

  $(document).on 'change', '.service-provider-checkbox', ->
    if $(this).prop('checked')
      $.ajax
        type: 'POST'
        url: '/catalog_manager/service_provider'
        data:
          service_provider:
            identity_id: $(this).data('identity-id')
            organization_id: $(this).data('organization-id')
    else
      $.ajax
        type: 'DELETE'
        url: "/catalog_manager/service_provider/"
        data:
          service_provider:
            identity_id: $(this).data('identity-id')
            organization_id: $(this).data('organization-id')

  $(document).on 'change', '.clinical-provider-checkbox', ->
    if $(this).prop('checked')
      $.ajax
        type: 'POST'
        url: '/catalog_manager/clinical_provider'
        data:
          clinical_provider:
            identity_id: $(this).data('identity-id')
            organization_id: $(this).data('organization-id')
    else
      $.ajax
        type: 'DELETE'
        url: "/catalog_manager/clinical_provider/"
        data:
          clinical_provider:
            identity_id: $(this).data('identity-id')
            organization_id: $(this).data('organization-id')

  $(document).on 'change', '.cm-edit-historic-data', ->
    console.log("edit historic data checkbox not implemented")

  $(document).on 'change', '.sp-is-primary-contact', ->
    console.log("is primary contact checkbox not implemented")

  $(document).on 'change', '.sp-hold-emails', ->
    console.log("hold emails checkbox not implemented")
