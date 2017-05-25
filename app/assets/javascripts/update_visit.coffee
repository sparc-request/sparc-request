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
$ ->

  $(document).on 'click', '.edit-billing-qty', ->
    id = $(this).data('id')
    portal = $(this).data('portal')
    srId = $(this).data('service-request-id')
    armId = $(this).data('arm-id')
    $.ajax
      type: 'GET'
      url: "/dashboard/visits/#{id}/edit?portal=#{portal}&&arm_id=#{armId}&&service_request_id=#{srId}"

  $(document).on 'ajax:success', '.visit-form', ->
    arm_id = $('.visit-form .v-arm-id').val()
    sr_id = $('.visit-form .v-sr-id').val()
    reload_calendar(arm_id, sr_id)
    $('#modal_place').modal('hide')

  $(document).on 'ajax:error', '.visit-form', (e, data, status, xhr) ->
    $('.visit-form').renderFormErrors('visit', jQuery.parseJSON(data.responseText))
