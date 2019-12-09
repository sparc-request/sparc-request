# Copyright © 2011-2019 MUSC Foundation for Research Development
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

$(document).ready ->
  $(document).on 'click', '#outsideUserLogin', ->
    console.log 'test'
    $('form#new_identity').removeClass('d-none')

  $(document).on('keydown', '#identity_orcid, #project_role_identity_attributes_orcid', (event) ->
    key = event.keyCode || event.charCode
    val = $(this).val()
    isDelete = [8, 46].includes(key)

    # Key must be numerical OR key must be X and last character of ID
    if !((key >= 96 && key <= 105) || (key >= 48 && key <= 57)) && !(key == 88 && val.length == 18) && !isDelete
      event.stopImmediatePropagation()
      return false
    else if isDelete && [6, 11, 16].includes(val.length)
      $(this).val(val.substr(0, val.length - 1))
    if !isDelete && [4, 9, 14].includes(val.length)
      $(this).val(val + "-")
    else if !isDelete && [5, 10, 15].includes(val.length) && val[val.length-1] != "-"
      $(this).val(val.substr(0, val.length - 1) + "-" + val.substr(val.length - 1, val.length))
    else if key == 88 && val.length == 18
      event.stopImmediatePropagation()
      $(this).val(val.substr(0, val.length) + String.fromCharCode(key).toUpperCase())
  ).on('keyup', '#identity_orcid, #project_role_identity_attributes_orcid', (event) ->
    key = event.keyCode || event.charCode
    val = $(this).val()
    isDelete = [8, 46].includes(key)

    if !isDelete && [4, 9, 14].includes(val.length)
      $(this).val(val + "-")
  )

  $(document).on 'changed.bs.select', '#identity_credentials, #project_role_identity_attributes_credentials', ->
    if $(this).val() == 'other'
      $('#credentialsOtherContainer').removeClass('d-none')
    else
      $('#credentialsOtherContainer').addClass('d-none')

  $(document).on 'changed.bs.select', '#professionalOrganizationForm select', ->
    last_selected = $(this).val()
    po_selected_id = $(this).closest('select').attr('id')
    if last_selected == '' && po_selected_id != 'select-pro-org-institution'
      last_selected = $(this).parents("div").prev().find('select').val()

    $.ajax
      method: 'get'
      dataType: 'script'
      url: '/associated_users/update_professional_organizations'
      data:
        last_selected_id: last_selected
