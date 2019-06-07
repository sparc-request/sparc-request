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

  $('.epic-queue-table').bootstrapTable()
  $('.epic-queue-records-table').bootstrapTable()

  $(document).on 'click', '.delete-epic-queue-button', ->
    if confirm(I18n['epic_queues']['confirm'])
      eq_id = $(this).data('epic-queue-id')
      $.ajax
        type: 'DELETE'
        url: "/dashboard/epic_queues/#{eq_id}.js"

  $(document).on 'click-cell.bs.table', '.epic-queue-table, .epic-queue-records-table', (field, value, row, $element) ->
    if value == 'protocol'
      protocolId = $element.protocol_id
      window.open("/dashboard/protocols/#{protocolId}")

  $(document).on 'click', '.push-to-epic', (e) ->
    e.preventDefault()
    protocol_id = $(this).data('protocol-id')
    eq_id = $(this).data('eq-id')
    $.ajax
      type: 'GET'
      url: "/protocols/#{protocol_id}/push_to_epic.js?from_portal=true&&eq_id=#{eq_id}"

  $(document).on 'click', '#epic-queue-panel .export button', ->
    $(this).parent().removeClass('open')
    window.location = '/dashboard/epic_queue_records.xlsx'
