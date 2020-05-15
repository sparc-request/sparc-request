# Copyright © 2011-2020 MUSC Foundation for Research Development
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

<% if @errors.any? %>
$('#protocol_research_master_id').parents('.form-group').addClass('is-invalid')

<% if @protocol.rmid_server_down %>
$('#protocol_research_master_id').val('').prop('disabled', true)
$('#rmidContainer').append("<%= j render 'protocols/form/rmid_server_down' %>")
<% else %>
AlertSwal.fire(
  type: 'error'
  title: "<%= Protocol.human_attribute_name(:research_master_id) %>"
  html: "<%= @errors.join('<br>').html_safe %>"
)
<% end %>
<% else %>
$('#protocol_research_master_id').parents('.form-group').addClass('is-valid')

$('#protocol_short_title').val("<%= @rmid_record['short_title'] %>").prop('readonly', true)
$('#protocol_title').val("<%= @rmid_record['long_title'] %>").prop('readonly', true)

<% if @rmid_record['eirb_validated'] %>
if !$('#protocol_research_types_info_attributes_human_subjects').prop('checked')
  $('#protocol_research_types_info_attributes_human_subjects').click()
  $('#protocol_research_master_id').click()
$.ajax
  method: 'POST'
  dataType: 'script'
  url: "<%= irb_records_path(irb_record: { pro_number: @rmid_record['eirb_pro_number'], initial_irb_approval_date: @rmid_record['date_initially_approved'], irb_approval_date: @rmid_record['date_approved'], irb_expiration_date: @rmid_record['date_expiration'] }, primary: 'true', index: 0) %>"
<% end %>
<% end %>
