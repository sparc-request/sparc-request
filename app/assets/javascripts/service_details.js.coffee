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

#= require navigation
#= require cart

$(document).ready ->
  $(document).on 'click', '#new-arm-button', ->
    $.ajax
      type: 'get'
      url: '/arms/new'
      data:
        protocol_id: $(this).data('protocol-id')
        srid: getSRId()
    return false

  $(document).on 'click', '.edit-arm-button', ->
    arm_id = $(this).data('arm-id')
    $.ajax
      type: 'get'
      url: "/arms/#{arm_id}/edit"
      data:
        srid: getSRId()

  $(document).on 'click', '#edit-arm-form-button', ->
    $(this).attr('disabled','disabled')
    $(this).closest('form').submit()

  $(document).on 'click', '.delete-arm-button', ->
    if confirm(I18n['arms']['delete_warning'])
      arm_id = $(this).data('arm-id')
      $.ajax
        type: 'delete'
        url: "/arms/#{arm_id}?srid=#{getSRId()}"

  $('#arms-table').on 'all.bs.table', ->
    $('.screening-info').tooltip()

  $('#arms-table').on 'all.bs.table', ->
    $('.name-validation').tooltip()
    $('.subject-count').tooltip()
    $('.visit-count').tooltip()


  $(document).on 'dp.change', '.initial-budget-sponsor-received-date-picker', ->
    $('.initial-amount').removeClass('hide')

  $(document).on 'dp.change', '.budget-agreed-upon-date-picker', ->
    $('.negotiated-amount').removeClass('hide')

  if $('.initial-budget-sponsor-received-date-picker').val() != ''
    $('.initial-amount').removeClass('hide')

  if $('.budget-agreed-upon-date-picker').val() != ''
    $('.negotiated-amount').removeClass('hide')
