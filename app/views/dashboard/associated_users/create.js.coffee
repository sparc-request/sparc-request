# Copyright © 2011-2022 MUSC Foundation for Research Development
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

<% if @errors %>
$("[name^='project_role']:not([type='hidden']), #professionalOrganizationForm select").parents('.form-group').removeClass('is-invalid').addClass('is-valid')
$('.form-error').remove()

<% @errors.messages.each do |attr, messages| %>
<% messages.each do |message| %>
$("[name='project_role[<%= attr.to_s %>]']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>

<% @protocol_role.identity.errors.messages.each do |attr, messages| %>
<% messages.each do |message| %>
$("[name='project_role[identity_attributes][<%= attr.to_s %>]']").parents('.form-group').removeClass('is-valid').addClass('is-invalid').append("<small class='form-text form-error'><%= message.capitalize.html_safe %></small>")
<% end %>
<% end %>
<% else %>

# Refresh content to update user rights
<% if @protocol_role.identity == current_user %>
$("#protocolSummaryCard").replaceWith("<%= j render 'protocols/summary', protocol: @protocol, protocol_type: @protocol_type, permission_to_edit: @permission_to_edit, admin: @admin %>")
$("#documentsCard").replaceWith("<%= j render 'documents/table', protocol: @protocol, permission_to_edit: @permission_to_edit || @admin  %>")
$('.service-request-card:not(:eq(0))').remove()
$(".service-request-card:eq(0)").replaceWith("<%= j render 'dashboard/service_requests/service_requests', protocol: @protocol, permission_to_edit: @permission_to_edit %>")

$("#documentsTable").bootstrapTable()
$(".service-requests-table").bootstrapTable()
<% end %>

$("#authorizedUsersTable").bootstrapTable('refresh')
$("#modalContainer").modal('hide')
$("#flashContainer").replaceWith("<%= j render 'layouts/flash' %>")
<% end %>
