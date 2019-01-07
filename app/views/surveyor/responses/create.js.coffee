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
<% if @response.valid? %>
<% if @response.survey.is_a?(Form) %>
$('#forms-panel').show()
$('#forms-table').bootstrapTable('refresh')
$('#modal_place').modal('hide')

if $('#protocol_show_information_panel').length >= 1
  $("#service-requests-panel").html("<%= escape_javascript(render('dashboard/service_requests/service_requests', protocol: @protocol, permission_to_edit: @permission_to_edit, user: current_user, view_only: false, show_view_ssr_back: false)) %>")
  $('.service-requests-table').bootstrapTable()
  reset_service_requests_handlers()
<% elsif @response.survey.is_a?(SystemSurvey) && @response.survey.system_satisfaction? %>
$('#modal_place').modal('hide')
<% else %>
  window.location = "/surveyor/responses/<%=@response.id%>/complete"
<% end %>
<% else %>
<% @response.question_responses.each do |qr| %>
<% if qr.valid? %>
$(".question-<%=qr.question_id%> .question-label").removeClass('has-error')
$(".question-<%=qr.question_id%> .question-label .help-block").remove()
<% else %>
if !$(".question-<%=qr.question_id%> .question-label").hasClass('has-error')
  $(".question-<%=qr.question_id%> .question-label").addClass('has-error')
  <% qr.errors.full_messages.each do |message| %>
  $(".question-<%=qr.question_id%> .question-label").append("<span class='help-block'><%= message %></span>")
  <% end %>
<% end %>
<% end %>
<% end %>
